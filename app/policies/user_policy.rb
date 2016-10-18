class UserPolicy
  attr_reader :user, :manager

  def initialize(user, manager)
    @user = user
    @manager = manager
  end

  def update?
    workmate?
  end

  private

  def workmate?
    @user.company == @manager.company
  end
end