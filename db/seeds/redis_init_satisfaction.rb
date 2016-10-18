# 本文件不再使用了，系统同步数据库中服务评价设置到redis。
# You can run this seed by `$ rake db:seed:redis_init_satisfaction`

puts "开始同步服务评价设置到redis"
Ivr.satisfaction.order(:id).each_with_index do |satisfaction, i|
  puts "#{i + 1} company_id: #{satisfaction.company_id} name: #{satisfaction.name}"

  root_node = Node.find(satisfaction.node_id)
  RedisHelp.add_ivr(satisfaction)
  RedisHelp.add_ivr_node(root_node, satisfaction.timeout_length, satisfaction.timeout_repeat, satisfaction.timeout_action, satisfaction.timeout_value, satisfaction.ivr_type)
  puts "-- root_node: #{root_node.id} name: #{root_node.name}"
  Node.where(parent_id: satisfaction.node_id).order(:id).each do |node|
    RedisHelp.add_ivr_node(node, satisfaction.timeout_length, satisfaction.timeout_repeat, satisfaction.timeout_action, satisfaction.timeout_value, satisfaction.ivr_type,)
    puts "-- -- node: #{node.id} name: #{node.name}"
  end

end