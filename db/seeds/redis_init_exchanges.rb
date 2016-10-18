# 本文件不再使用了，系统同步数据库中企业彩铃设置到redis。
# You can run this seed by `$ rake db:seed:redis_init_exchanges`

puts "开始同步企业总机reids"
Ivr.exchange.order(:id).each_with_index do |exchange, i|
  puts "#{i + 1} company_id: #{exchange.company_id} name: #{exchange.name}"
  root_node = Node.find(exchange.node_id)
  puts "-- root_node: #{root_node.id} name: #{root_node.name}"
  RedisHelp.add_ivr_node(root_node, exchange.timeout_length, exchange.timeout_repeat, exchange.timeout_action, exchange.timeout_value, exchange.ivr_type)
  Node.where(parent_id: exchange.node_id).order(:id).each do |node|
    RedisHelp.add_ivr_node(node, exchange.timeout_length, exchange.timeout_repeat, exchange.timeout_action, exchange.timeout_value, exchange.ivr_type,)
    puts "---- node: #{node.id} name: #{node.name}"
  end
  RedisHelp.add_ivr(exchange)

end