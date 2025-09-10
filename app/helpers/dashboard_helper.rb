module DashboardHelper
  def db_tool_schema_status(tool)
    spec = safe_arguments(tool)

    ok, msg = Tool.validate_schema_structure(spec)
    if ok
      begin
        require 'dry/schema'
        Tool.build_dry_schema_from(spec)
        { ok: true, message: 'Schema is valid' }
      rescue LoadError
        { ok: true, message: 'Schema structure valid (dry-schema not loaded)' }
      rescue StandardError => e
        { ok: false, message: "dry-schema error: #{e.message}" }
      end
    else
      { ok: false, message: msg }
    end
  end

  def schema_status_badge(tool)
    status = db_tool_schema_status(tool)
    classes = ["badge", status[:ok] ? "ok" : "err"].join(' ')
    content_tag(:span, (status[:ok] ? 'valid' : 'invalid'), class: classes, title: status[:message])
  end

  def pretty_json(obj)
    JSON.pretty_generate(obj)
  rescue StandardError
    obj.to_s
  end

  private

  def safe_arguments(tool)
    args = tool.arguments
    args.is_a?(Hash) ? args : {}
  rescue StandardError
    {}
  end
end

