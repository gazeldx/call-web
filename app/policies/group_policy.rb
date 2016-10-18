class GroupPolicy
  attr_reader :user, :group

  def initialize(user, group)
    @user = user
    @group = group
  end

  def create?
    have_menu_workmate? && inbound_or_agent_belong_to_only_one_outbound_group? && !outbound_group_contain_manual_call_charge_agent?
  end

  def update?
    have_menu_workmate? && inbound_or_agent_belong_to_only_one_outbound_group? && !outbound_group_contain_manual_call_charge_agent?
  end

  def destroy?
    have_menu_workmate?
  end

  private

  def workmate?
    @user.company == @group.company
  end

  def have_menu_workmate?
    workmate? && @user.have_menu?('group.management')
  end

  def agent_belong_to_only_one_outbound_group?
    (@group.agents.map(&:id) & AgentsGroups.where(group_id: @group.company.groups.outbound.pluck(:id) - [@group.id]).pluck(:agent_id)).blank?
  end

  def inbound_or_agent_belong_to_only_one_outbound_group?
    !@group.outbound? || agent_belong_to_only_one_outbound_group?
  end

  # 计费方案设定为手拨类型的座席，不允许被加入到呼出组
  def outbound_group_contain_manual_call_charge_agent?
    @group.outbound? && ChargeAgent.exists?(charge_id: ChargeAgent.manual_charge_ids, agent_id: @group.agents.map(&:id))
  end
end