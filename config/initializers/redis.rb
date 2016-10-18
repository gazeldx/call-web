require 'connection_pool'

$redis = ConnectionPool::Wrapper.new(size: 5, timeout: 3) do
  Redis.new(host: Settings.freeswitch.redis.host, port: Settings.freeswitch.redis.port)
end

# Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379)