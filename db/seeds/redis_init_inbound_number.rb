# 本文件不再使用了，系统同步数据库中呼入号码到redis。
# You can run this seed by `$ rake db:seed:redis_init_inbound_number`

puts "开始同步呼入号码到redis"
Number.order(:id).each_with_index do |number, i|
  puts "#{i + 1} company_id: #{number.company_id}  number: #{number.number} "

  RedisHelp.add_inbound_number(number.inbound_config) if number.company_id.present? && number.inbound_config.present?
end