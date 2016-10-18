class Menu2Policy < Struct.new(:user, :menu2)
  attr_reader :user

  def initialize(user, menu2)
    @user = user
  end

  def has_ivr?
    (Bundle::IVR_MENUS.values & @user.company.menus.map(&:name)).any?
  end

  def vip?
    menu_names.include?('ivr.vip')
  end

  private

  def menu_names
    @user.company.menus.map(&:name)
  end
end