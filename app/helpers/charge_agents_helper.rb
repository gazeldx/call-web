module ChargeAgentsHelper
  def charge_agent_info(agent)
    "#{agent.charge_agent.try(:charge_id)} - #{agent.charge_agent.try(:charge_name)} #{agent.charge_agent.try(:charge_kind_show)}，#{t('charge_agent.monthly_rent')}: #{agent.charge_agent.try(:monthly_rent)}元" +
    " #{ChargeAgent.get_class_name_by_charge_id(agent.charge_agent.try(:charge_id)) == ChargeAgentExceedFree ? "保底冻结余额：#{agent.charge_agent.min_fee_balance.try(:round, 2)}元" : nil}" +
    " #{ChargeAgent.get_class_name_by_charge_id(agent.charge_agent.try(:charge_id)) == ChargeAgentMinutely ? "剩余分钟数：#{agent.charge_agent.minutes}" : nil}"
  end
end
