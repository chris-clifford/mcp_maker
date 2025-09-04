class McpController < ApplicationController
  # GET /mcp
  def index
    render json: {
      status: 'ok',
      name: Rails.application.class.module_parent_name.underscore.dasherize,
      version: '1.0.0',
      endpoints: {
        messages: '/mcp/messages',
        sse: '/mcp/sse'
      },
      tools: list_tools
    }
  end

  private

  def list_tools
    # Only list tools if Fast MCP is available and ApplicationTool is defined
    return [] unless defined?(ActionTool::Base)
    return [] unless Object.const_defined?(:ApplicationTool)

    ::ApplicationTool.descendants.map do |tool|
      { name: tool.name, description: tool.try(:description) }
    end
  end
end
