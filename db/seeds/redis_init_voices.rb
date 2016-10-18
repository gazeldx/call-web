# 本文件不再使用了，系统同步数据库中语音文件到redis。
# You can run this seed by `$ rake db:seed:redis_init_voices`

puts "开始同步语音文件到redis"
Voice.order(:id).each_with_index do |voice, i|
  puts "#{i + 1} company_id: #{voice.company_id} name: #{voice.name}"
  RedisHelp.add_voice(voice)
end