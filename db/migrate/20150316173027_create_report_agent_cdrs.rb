# 模块：Report
class CreateReportAgentCdrs < ActiveRecord::Migration
  def change
    # 坐席呼叫总量日计数表(TODO: 暂时不用了，改为存储在Redis中, 和张林剑确认后再删除本表.)
    create_table :report_agent_cdrs do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :agent, index: true
      t.belongs_to  :salesman, index: true
      t.date        :target_date #统计日期
      t.integer     :trigger_count #呼叫数量
    end
  end
end
