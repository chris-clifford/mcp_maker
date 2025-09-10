class DashboardController < ApplicationController
  # GET /mcp
  def index
    load_mcp_classes

    @tools = list_tools
    @resources = list_resources
    @prompts = list_prompts
    @schemas = list_schemas
    @db_tools = fetch_db_tools

    respond_to do |format|
      format.html
      format.json do
        render json: {
          status: 'ok',
          name: Rails.application.class.module_parent_name.underscore.dasherize,
          version: '1.0.0',
          endpoints: {
            messages: '/mcp/messages',
            sse: '/mcp/sse'
          },
          tools: @tools,
          resources: @resources,
          prompts: @prompts,
          schemas: @schemas
        }
      end
    end
  end

  # GET /dashboard/new
  def new
    # Mock page for creating a new Tool/Resource/Prompt/Schema
  end

  private

  def list_tools
    return [] unless defined?(ActionTool::Base) && Object.const_defined?(:ApplicationTool)

    ::ApplicationTool.descendants.map do |tool|
      {
        name: tool.name,
        description: tool.respond_to?(:description) ? tool.description : nil
      }
    end
  end

  def list_resources
    return [] unless defined?(ActionResource::Base) && Object.const_defined?(:ApplicationResource)

    ::ApplicationResource.descendants.map do |resource|
      uri = resource.respond_to?(:uri) ? resource.uri : nil
      {
        name: resource.name,
        uri: uri,
        description: resource.respond_to?(:description) ? resource.description : nil
      }
    end
  end

  def list_prompts
    # Placeholder: list prompts if the library exposes them in future
    []
  end

  def list_schemas
    # Placeholder: list schemas if the library exposes them in future
    []
  end

  def load_mcp_classes
    # Load tool/resource definitions so descendants tracking works in dev
    tools_path = Rails.root.join('app', 'tools')
    resources_path = Rails.root.join('app', 'resources')
    Dir[tools_path.join('**', '*.rb')].sort.each { |f| require_dependency f } if tools_path.directory?
    Dir[resources_path.join('**', '*.rb')].sort.each { |f| require_dependency f } if resources_path.directory?
  end

  def fetch_db_tools
    return [] unless defined?(::Tool)

    ::Tool.all
  rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError
    []
  end
end
