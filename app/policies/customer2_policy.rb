# This is https://github.com/elabs/pundit#headless-policies
class Customer2Policy < Struct.new(:user)
  attr_reader :user

  def initialize(user, headless)
    @user = user
  end

  def delete?
    @user.admin?
  end

  def batch_delete?
    @user.admin?
  end
end