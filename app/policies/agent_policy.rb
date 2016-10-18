class AgentPolicy
  attr_reader :user, :agent

  def initialize(user, agent)
    @user = user
    @agent = agent
  end

  def modify_groups?
    workmate? && @user.admin?
  end

  def update?
    workmate? && @agent.ok? && show_number_exist?
  end

  def destroy?
    user.is_a?(Administrator) && (@agent.ok? || @agent.disabled_eom?)
  end

  def disable_eom?
    @agent.ok? && DisabledAgent.where(agent_id: @agent.id).where("created_at > '#{DateTime.parse(Time.now.strftime("%Y-%m-") + "01")}'").blank?
  end

  def enable?
    user.is_a?(Administrator) && @agent.disabled? && @agent.company.phone_numbers.agent_numbers.present?
  end

  private

  def workmate?
    @user.company == @agent.company
  end

  def show_number_exist?
    @agent.company.phone_numbers.agent_numbers.any? { |agent_number| agent_number.number ==  @agent.show_number }
  end
end