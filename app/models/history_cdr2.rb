# 因为DB HA后, 查询用的是HistoryCdr, 查的是ReadOnly的DB Slave;
# 而在删除时, 就要用到本HistoryCdr2了, 操作DB Master.
class HistoryCdr2 < ActiveRecord::Base
  self.table_name = 'history_cdrs'
end
