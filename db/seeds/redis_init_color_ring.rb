# 本文件不再使用了，系统同步数据库中企业彩铃设置到redis。
# You can run this seed by `$ rake db:seed:redis_init_color_ring`

puts "开始同步企业彩铃reids"
Ivr.color_ring.order(:id).each_with_index do |color_ring, i|
  puts "#{i + 1} company_id: #{color_ring.company_id} name: #{color_ring.name}"
  RedisHelp.add_color_ring(color_ring)
end