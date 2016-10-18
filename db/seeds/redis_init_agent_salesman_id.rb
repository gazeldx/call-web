# 本文件不再使用了，系统同步数据库中语音文件到redis。
# You can run this seed by `$ rake db:seed:redis_init_agent_salesman_id`

puts "开始初始化座席的salesman_id信息到redis..."
Agent.where('salesman_id > 0').order(:id).each_with_index do |agent, i|
  puts "#{i + 1} agent_id: #{agent.id} salesman_id: #{agent.salesman_id}"
  RedisHelp.set_agent_salesman_id(agent.id, agent.salesman_id)
end
puts "已完成"