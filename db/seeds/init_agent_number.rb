# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:init_agent_number`
Agent.where('shown_number_id > 0').each_with_index do |agent, i|
  agent.show_number = Number.find(agent.shown_number_id).try(:number)
  agent.save!

  puts "agent #{i} processed"
end