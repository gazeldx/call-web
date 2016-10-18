# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_10001_charge_agents`
(Company.find(10001).agents.pluck(:id) - ChargeAgent.where(agent_id: Company.find(10001).agents.pluck(:id)).pluck(:agent_id)).each_with_index do |agent_id, i|
  puts "agent_id: #{agent_id} processing"
  ChargeAgent.create!(agent_id: agent_id,
                      charge_id: nil,
                      monthly_rent: 0,
                      minutes: 0,
                      min_fee_balance: 0)
end