# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:fs_redis_set_out_available_for_a_company`
Company.find(60108).agents.each do |agent|
  if (agent.disabled_eom?)
    puts "Set available #{agent.id}"

    $redis.set("OUT:#{agent.id}", 'Available')
  end
end