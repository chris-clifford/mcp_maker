class Tool < ApplicationRecord
  validates :description, presence: true
  validates :arguments, presence: true
  validates :call_action, presence: true

  validate :arguments_mappable_to_dry_schema

  # Ensure arguments is always a Hash for convenience
  def arguments
    value = super
    value.is_a?(String) ? JSON.parse(value) : (value || {})
  rescue JSON::ParserError
    {}
  end

  private

  def arguments_mappable_to_dry_schema
    schema = arguments

    unless schema.is_a?(Hash)
      errors.add(:arguments, 'must be a JSON object mapping field names to definitions')
      return
    end

    ok, message = self.class.validate_schema_structure(schema)
    unless ok
      errors.add(:arguments, message)
      return
    end

    begin
      require 'dry/schema'
      # Attempt to compile a Dry::Schema from the JSON spec to ensure compatibility
      self.class.build_dry_schema_from(schema)
    rescue LoadError
      # dry-schema not available in this environment; structural validation is sufficient
      true
    rescue StandardError => e
      errors.add(:arguments, "not compatible with dry-schema: #{e.message}")
    end
  end

  def self.validate_schema_structure(spec, path_prefix = [])
    allowed_types = %w[string integer float boolean hash array]

    return [false, 'arguments cannot be empty'] if spec.empty?

    spec.each do |field, conf|
      return [false, "#{(path_prefix + [field]).join('.')} must be an object"] unless conf.is_a?(Hash)

      type = conf['type']
      return [false, "#{(path_prefix + [field]).join('.')} missing type"] unless type
      return [false, "#{(path_prefix + [field]).join('.')} has unsupported type '#{type}'"] unless allowed_types.include?(type)

      if conf.key?('required') && ![true, false].include?(conf['required'])
        return [false, "#{(path_prefix + [field]).join('.')} required must be boolean if present"]
      end

      case type
      when 'hash'
        props = conf['properties']
        return [false, "#{(path_prefix + [field]).join('.')} (hash) requires properties"] unless props.is_a?(Hash) && props.any?
        ok, msg = validate_schema_structure(props, path_prefix + [field])
        return [ok, msg] unless ok
      when 'array'
        items = conf['items']
        return [false, "#{(path_prefix + [field]).join('.')} (array) requires items type"] unless items
        if items.is_a?(String)
          return [false, "#{(path_prefix + [field]).join('.')} items has unsupported type '#{items}'"] unless %w[string integer float boolean].include?(items)
        elsif items.is_a?(Hash)
          # Allow array of hashes: items => { type: 'hash', properties: {...} }
          ok, msg = validate_schema_structure({ '__array_item__' => items }, path_prefix + [field])
          return [ok, msg] unless ok
        else
          return [false, "#{(path_prefix + [field]).join('.')} items must be a string or object"]
        end
      end
    end

    [true, nil]
  end

  def self.build_dry_schema_from(spec)
    type_map = {
      'string' => :string,
      'integer' => :integer,
      'float' => :float,
      'boolean' => :bool
    }

    Dry::Schema.define do
      define_singleton_method(:build_block) do |properties|
        properties.each do |name, conf|
          presence = conf['required'] ? :required : :optional
          type = conf['type']

          case type
          when 'string', 'integer', 'float', 'boolean'
            send(presence, name.to_sym).filled(type_map.fetch(type))
          when 'hash'
            send(presence, name.to_sym).hash do
              build_block.call(conf['properties'])
            end
          when 'array'
            items = conf['items']
            if items.is_a?(String)
              send(presence, name.to_sym).array(type_map.fetch(items))
            elsif items.is_a?(Hash)
              send(presence, name.to_sym).array(:hash) do
                if items['type'] == 'hash'
                  build_block.call(items['properties'])
                end
              end
            end
          else
            raise ArgumentError, "Unsupported type: #{type}"
          end
        end
      end

      build_block.call(spec)
    end
  end
end
