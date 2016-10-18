class IssueItemPolicy
  attr_reader :user, :issue_item

  def initialize(user, issue_item)
    @user = user
    @issue_item = issue_item
  end

  def create?
    workmate?
  end

  private

  def workmate?
    @user.company == @issue_item.company && @user.company == @issue_item.issue.company
  end
end