class SalesmanPolicy
  attr_reader :user, :salesman

  def initialize(user, salesman)
    @user = user
    @salesman = salesman
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  private

  def workmate?
    @user.company == @salesman.company
  end

  def admin?
    workmate? && @user.admin?
  end
end