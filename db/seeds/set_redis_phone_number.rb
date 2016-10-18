# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:set_redis_phone_number`
phone_numbers = PhoneNumber.where('expire_at > ?', Time.now + 4.days - 10.hours).where('expire_at < ?', Time.now + 6.days)

phone_numbers.each_with_index do |phone_number, i|
  puts "#{i} #{phone_number.inspect}"

  if phone_number.expire_at > Time.now
    puts "yes"
    $redis.set("acdqueue:tenant_number:caller_number:#{phone_number.company_id}:#{phone_number.number}", phone_number.expire_at.strftime("%Y-%m-%d %H:%M:%S"))
  end
end
