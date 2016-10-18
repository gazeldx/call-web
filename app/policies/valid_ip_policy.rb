class ValidIpPolicy
  attr_reader :user, :valid_ip

  def initialize(user, valid_ip)
    @user = user
    @valid_ip = valid_ip
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  private

  def workmate?
    @user.company == @valid_ip.company
  end

  def admin?
    workmate? && @user.admin?
  end
end