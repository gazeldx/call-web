class BundlePolicy
  attr_reader :user, :bundle

  def initialize(user, bundle)
    @user = user
    @bundle = bundle
  end

  def create_task?
    @bundle.tasks.running_and_before.count < Bundle::MAX_TASKS && @bundle.tasks.count < Bundle::MAX_TASKS_MOST
  end

  def update?
    workmate? && @bundle.tasks.running.blank?
  end

  def stash?
    workmate? && @bundle.tasks.running.blank?
  end

  def destroy?
    workmate? && @bundle.tasks.running.blank?
  end

  def workmate?
    @user.company == @bundle.company
  end
end