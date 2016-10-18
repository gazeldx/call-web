# 本文件不再使用了，系统同步数据库中呼入 IVR 到redis。
# You can run this seed by `$ rake db:seed:redis_init_ivr`

def init_child_nodes(node)
  node.child_nodes.each do |n|
    RedisHelp.add_ivr_node(n, n.ivr.timeout_length, n.ivr.timeout_repeat, n.ivr.timeout_action, n.ivr.timeout_value, n.ivr.ivr_type)
    init_child_nodes(n)
  end
end


puts "开始同步IVR设置到redis"
Ivr.only_ivr.order(:id).each_with_index do |ivr, i|
  puts "#{i + 1} company_id: #{ivr.company_id} name: #{ivr.name}"
  root_node = Node.find(ivr.node_id)
  RedisHelp.add_ivr(ivr)
  RedisHelp.add_ivr_node(root_node, ivr.timeout_length, ivr.timeout_repeat, ivr.timeout_action, ivr.timeout_value, ivr.ivr_type)
  init_child_nodes(root_node)
end