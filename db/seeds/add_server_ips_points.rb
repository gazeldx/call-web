# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:add_server_ips_points`
Point.create!(name: 'server_ip.management')

puts "Point server_ip.management added!"