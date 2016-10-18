class ChargeChangePolicy
  attr_reader :user, :charge_change

  def initialize(user, charge_change)
    @user = user
    @charge_change = charge_change
  end

  def create?
    if @charge_change.agent_id
      (@charge_change.company.charge_company.available_agent_charges.map(&:id) - [@charge_change.agent.charge_agent.charge_id]).include?(@charge_change.charge_id) \
        && @charge_change.agent.charge_changes.where(effective_at: Date.today.at_beginning_of_month.next_month).blank?
    else
      # 什么都没改是不允许的
      !([@charge_change.company.charge_company.charge_company_outbound_id, @charge_change.company.charge_company.charge_company_400_id].include?(@charge_change.charge_id) && @charge_change.min_fee.blank? ) \
        && @charge_change.company.charge_changes.where(agent_id: nil).where("charge_id > ? and charge_id < ? ", @charge_change.charge_id.to_f.floor2(-3), @charge_change.charge_id.to_f.floor2(-3) + 1000).where(effective_at: Date.today.at_beginning_of_month.next_month).blank?
    end
  end

  def agent_charge_changed?
    (@charge_change.company.charge_company.available_agent_charges.map(&:id) - [@charge_change.agent.charge_agent.charge_id]).include?(@charge_change.charge_id)
  end
end