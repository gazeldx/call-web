# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:fs_redis_init_agent_contact_number`
contact_numbers = $redis.keys("acdqueue:agent:contact_number:*")
puts "contact_numbers.size is #{contact_numbers.size}"
$redis.del(contact_numbers) unless contact_numbers.blank?

Company.order(:id).each_with_index do |company, i|
  puts "#{i + 1} company: #{company.id}"

  company.agents.each do |agent|
    if (agent.ok? || agent.disabled_eom?)
      puts "Add #{agent.contact_number.inspect} #{agent.id.inspect}" if agent.contact_number != agent.id
      $redis.set("acdqueue:agent:contact_number:#{agent.contact_number}", agent.id)
    end
  end
end