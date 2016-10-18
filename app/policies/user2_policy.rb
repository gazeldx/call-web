#This is https://github.com/elabs/pundit#headless-policies
class User2Policy < Struct.new(:user, :user2)
  attr_reader :user

  def initialize(user, headless)
    @user = user
  end

  def manage_many_teams?
    @user.teams_.count > 1
  end

  def view_phone_number?
    @user.have_menu?('customer.view_phone_number')
  end

  def export_customers?
    @user.have_menu?('customer.export')
  end
end