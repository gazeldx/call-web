#This is https://github.com/elabs/pundit#headless-policies
class RecordPackage2Policy < Struct.new(:user, :record_package2)
  attr_reader :user

  def initialize(user, headless)
    @user = user
  end

  def download?
    @user.have_menu?('record.list')
  end
end