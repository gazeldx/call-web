# This is https://github.com/elabs/pundit#headless-policies
class Group2Policy < Struct.new(:user)
  attr_reader :user

  def initialize(user, headless)
    @user = user
  end

  def modify_groups?
    @user.admin?
  end
end