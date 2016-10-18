# 本文件不再使用了，系统同步数据库中呼入策略设置到redis。
# You can run this seed by `$ rake db:seed:redis_init_strategy`

puts "开始同步呼入策略设置到redis"
Strategy.order(:id).each_with_index do |strategy, i|
  puts "#{i + 1} company_id: #{strategy.company_id} name: #{strategy.group_name}"
  RedisHelp.add_strategy(strategy)
  strategy_ids = Strategy.get_strategy_ids(strategy.group_id)
  RedisHelp.add_strategy_list(strategy.group_id, strategy_ids)
end
