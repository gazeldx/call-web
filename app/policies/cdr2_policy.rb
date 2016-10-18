#This is https://github.com/elabs/pundit#headless-policies
class Cdr2Policy < Struct.new(:user, :cdr2)
  attr_reader :user

  def initialize(user, headless)
    @user = user
  end

  def view?
    @user.is_a?(User) || @user.is_a?(Salesman)
  end

  def export?
    @user.have_menu?('cdr.export')
  end

  def download_record?
    @user.have_menu?('record.download')
  end

  def view_fee?
    @user.have_menu?('cdr.view_fee')
  end
end