# 模块：Report
class CreateReportAgentDailies < ActiveRecord::Migration
  def change
    # 日报表
    create_table :report_agent_dailies do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :agent, index: true
      t.belongs_to  :salesman, index: true
      t.date        :target_date #统计日期
      t.integer     :trigger_count #呼叫数量
      t.integer     :answer_count #应答数量
      t.integer     :talk_count #通话数量
      t.integer     :talk_duration #通话总时长，单位：秒
      t.integer     :average_duration #平均通话时长，单位：秒
      t.integer     :checkin_duration #签到总时长，单位：秒
      t.integer     :checkin_count #签到次数
    end

    # add_column :report_agent_dailies, :cost, :float, default: 0 #费用
    # add_column :report_agent_dailies, :talk_minutes, :integer, default: 0 #通话时长按分钟数计，如：通话3秒算一分钟，通话138秒算三分钟
    # add_column :report_agent_dailies, :call_type, :integer # 呼叫类型 {0: 呼出, 1: 呼入}
  end
end
