# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:delete_outbound_numbers`
deleted_count = Number.where('inbound = false or inbound is null').delete_all

puts "#{deleted_count} outbound numbers deleted!"