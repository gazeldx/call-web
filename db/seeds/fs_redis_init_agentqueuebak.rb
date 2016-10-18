# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:fs_redis_init_agentqueuebak`
i = 0

Group.all.each do |group|
  group.ags.each do |ag|
    i = i + 1
    puts "#{i} group_id: #{group.id}, agent_id: #{ag.agent_id}, level: #{ag.level_as_word}"

    if group.outbound?
      $redis.rpush("acdqueue:agentqueuebak:#{group.id}", ag.agent_id)
    else
      $redis.rpush("acdqueue:agentqueuebak:#{ag.level_as_word}:#{group.id}", ag.agent_id)
    end
  end
end