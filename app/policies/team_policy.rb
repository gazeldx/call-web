class TeamPolicy
  attr_reader :user, :team

  def initialize(user, team)
    @user = user
    @team = team
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
    @user.company == @team.company
  end

  def admin?
    workmate? && @user.admin?
  end
end