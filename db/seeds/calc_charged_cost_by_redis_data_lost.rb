# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:calc_charged_cost_by_redis_data_lost`
monthly_ids = ChargeAgentMonthly.pluck(:id)
agent_ids = ChargeAgent.where(charge_id: monthly_ids).pluck(:agent_id)
final_agent_ids = Agent.where(state: [Agent::STATE_OK, Agent::STATE_DISABLED_EOM], id: agent_ids).pluck(:id)
reports = ReportAgentDaily.where(target_date: "2015-11-25", agent_id: final_agent_ids).select("company_id, sum(cost) as cost").group('target_date', 'company_id')

reports.sort_by { |report| report.cost }.reverse!.each_with_index do |report, i|
  puts "#{i + 1} #{report.company_id} 补: #{report.cost}" if report.cost > 0
end