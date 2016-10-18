class SalesmanBaseController < ApplicationController
  skip_before_filter :check_logged
  before_filter :check_session

  private

  def check_session
    redirect_to login_path unless salesman?
  end
end
