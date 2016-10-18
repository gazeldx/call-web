#This is https://github.com/elabs/pundit#headless-policies
class SystemPolicy < Struct.new(:user, :system)
  attr_reader :user

  def initialize(user, headless)
    @user = user
  end

  def free_time?
    SystemConfig.free_time?
  end
end