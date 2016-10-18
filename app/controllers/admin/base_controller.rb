class Admin::BaseController < ApplicationController
  skip_before_filter :check_logged
  before_filter :check_session

  private

  def check_session
    redirect_to admin_login_path unless admin?
  end
end
