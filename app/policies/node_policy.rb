class NodePolicy
  attr_reader :user, :node

  def initialize(user, node)
    @user = user
    @node = node
  end

  def update?
    workmate?
  end

  private

  def workmate?
    @user.company == @node.company
  end
end