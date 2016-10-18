# 本文件不再使用了，系统同步数据库中语音文件到redis。
# You can run this seed by `$ rake db:seed:redis_init_group`

puts "开始同步group信息到redis"
Group.inbound.order(:id).each_with_index do |group, i|
  puts "#{i + 1} group_id: #{group.id} name: #{group.name}"
  RedisHelp.add_group(group)
end