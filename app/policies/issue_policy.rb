class IssuePolicy
  attr_reader :user, :issue

  def initialize(user, issue)
    @user = user
    @issue = issue
  end

  def create?
    workmate?
  end
  
  def update?
    workmate?
  end

  def show?
    workmate?
  end

  def popup?
    workmate? && issue.handler_id == @user.id
  end

  private

  def workmate?
    @user.company == @issue.company && @user.company == @issue.handler.company
  end
end