class ReportAgentDaily < ActiveRecord::Base
  CACHED_MINUTES = 10 # 统计报表下一次查询的时间间隔(因为考虑cdrs表数据量比较大, 如果每次查询都实时统计会影响性能。所以页面做了限制, 只有过了 CACHED_MINUTES 分钟后才可以查询最新结果。上次查询的结果会被缓存在Redis中。)

  CALL_TYPE_OUTBOUND = 0
  CALL_TYPE_INBOUND = 1
  CALL_TYPES = [CALL_TYPE_OUTBOUND, CALL_TYPE_INBOUND]

  belongs_to  :company
  belongs_to  :agent
  belongs_to  :salesman

  def answer_ratio
    "#{self.trigger_count > 0 ? ((self.answer_count.to_f / self.trigger_count) * 100).round(1) : 0}%"
  end
end
