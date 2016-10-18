class TaskPolicy
  attr_reader :user, :task

  def initialize(user, task)
    @user = user
    @task = task
  end

  def start?
    workmate? && (@task.init? || @task.ready? || @task.paused?) \
      && @task.bundle.group.state == Group::STATE_OK \
      && @task.remains_count > 0 && (@task.started_at.nil? || Time.now - @task.started_at > 30.seconds) \
      && @task.bundle.tasks.running.count < Bundle::MAX_RUNNING_TASKS \
      && @task.bundle.group.running_bundle.nil? \
      && @task.bundle.number_are_for_task_if_predict? && @task.bundle.task_numbers_not_expired_if_predict? && @task.bundle.agents_number_not_expired_if_automatic? \
      && ((Time.now > Time.parse('08:00', Time.now) && Time.now < Time.parse('20:00', Time.now)) || [60109, 60071, 10015, 60383, 60711].include?(@task.company.id))
  end

  def pause?
    workmate? && @task.running?
  end

  def create?
    workmate? && @user.company.task_config.present? && @task.bundle.tasks.running_and_before.count < Bundle::MAX_TASKS && @task.bundle.active?
  end

  def update?
    workmate?
  end

  def destroy?
    workmate? && (@task.stashed? || @task.finished?)
  end

  def stash?
    workmate? && (@task.init? || @task.ready? || @task.paused?)
  end

  def resume?
    workmate? && @task.stashed? && @task.remains_count > 0 && not_cleaned? && @task.bundle.tasks.running_and_before.count < Bundle::MAX_TASKS_FOR_RESUME
  end

  def import_numbers?
    workmate? && @task.init? && @task.phone_count < Task::MAX_TASK_PHONES && @task.bundle.active?
  end

  def export?
    manager? && (@task.init? || @task.ready? || @task.paused? || (@task.stashed? && not_cleaned?)) && @task.remains_count > 0
  end

  private

  def workmate?
    @user.company == @task.company
  end

  def manager?
    workmate? && (@user.admin? || @user.bundles.pluck(:id).include?(@task.bundle.id))
  end

  def not_cleaned?
    Time.now - @task.updated_at < Task::MAX_PHONE_NUMBERS_KEPT_DAYS.days
  end
end