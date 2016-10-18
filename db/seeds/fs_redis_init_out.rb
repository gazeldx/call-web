# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:fs_redis_init_out`
Company.order(:id).each_with_index do |company, i|
  puts "#{i + 1} company: #{company.id}"

  company.agents.each do |agent|
    if (agent.ok? || agent.disabled_eom?)
      puts "Set available #{agent.id}"

      $redis.set("OUT:#{agent.id}", 'Available')
    end
  end
end