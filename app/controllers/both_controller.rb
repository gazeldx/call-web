# Notice: Salesman和User共用一个功能时，可以用本类作为父类
class BothController < ApplicationController
  skip_before_filter :check_logged
  before_filter :check_session

  private

  def check_session
    redirect_to login_path unless (user? || salesman?)
  end
end
