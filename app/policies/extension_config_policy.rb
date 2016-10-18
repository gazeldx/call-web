# Notice: 目前本文件没有被使用
class ExtensionConfigPolicy
  attr_reader :user, :extension_config

  def initialize(user, extension_config)
    @user = user
    @extension_config = extension_config
  end

  def update?
    workmate?
  end

  private

  def workmate?
    @user.company == @extension_config.company
  end
end