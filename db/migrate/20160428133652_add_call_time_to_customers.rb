class AddCallTimeToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :call_time, :timestamp # 最近一次呼叫的时间（目前仅在页面点击呼叫时记录）
  end
end