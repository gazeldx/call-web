class AdministratorPolicy
  attr_reader :user, :administrator

  def initialize(user, administrator)
    @user = user
    @administrator = administrator
  end

  def create?
    @user.admin?
  end

  def update?
    @user.admin?
  end
end