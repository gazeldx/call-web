# 本文件不再使用了，系统同步数据库中企业分机号设置到redis。
# You can run this seed by `$ rake db:seed:redis_init_extension`

puts "开始同步分机号设置到redis"
ExtensionConfig.order(:id).each_with_index do |extension, i|
  puts "#{i + 1} agent_id: #{extension.agent_id}"
  RedisHelp.add_extension(extension)
end