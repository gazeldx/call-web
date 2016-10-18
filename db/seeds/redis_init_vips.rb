# 本文件不再使用了，系统同步数据库中企业彩铃设置到redis。
# You can run this seed by `$ rake db:seed:redis_init_vips`

puts "开始同步vip设置到redis"
Vip.order(:id).each_with_index do |vip, i|
  puts "#{i + 1} company_id: #{vip.company_id} name: #{vip.name}"
  RedisHelp.add_vip(vip) if vip.status
end