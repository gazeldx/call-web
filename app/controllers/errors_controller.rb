class ErrorsController < ApplicationController
  layout 'bone'

  def not_found
    render(status: 404)
  end

  def internal_server_error
    # "#{env["action_dispatch.exception"].class.to_s} #{env["action_dispatch.exception"].message}"
    flash[:exception] = env["action_dispatch.exception"].inspect

    render(status: 500)
  end
end
