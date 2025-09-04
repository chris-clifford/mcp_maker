# Configure Fast MCP Rails integration
begin
  require 'fast_mcp'

  FastMcp.mount_in_rails(
    Rails.application,
    name: Rails.application.class.module_parent_name.underscore.dasherize,
    version: '1.0.0',
    path_prefix: '/mcp',
    messages_route: 'messages',
    sse_route: 'sse'
    # allowed_origins: ['localhost', '127.0.0.1'],
    # localhost_only: true,
    # allowed_ips: ['127.0.0.1', '::1'],
    # authenticate: true,
    # auth_token: ENV['FAST_MCP_AUTH_TOKEN']
  ) do |server|
    Rails.application.config.after_initialize do
      # Auto-register any ActionTool/ActionResource descendants
      server.register_tools(*ApplicationTool.descendants) if defined?(ApplicationTool)
      server.register_resources(*ApplicationResource.descendants) if defined?(ApplicationResource)
    end
  end
rescue LoadError
  # fast-mcp not installed in this environment; initializer remains harmless
end

