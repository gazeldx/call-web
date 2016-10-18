# 模块：Outbound
# 表名：企业任务参数设置
class CreateCompanyTaskConfig < ActiveRecord::Migration
  def change
    create_table :company_task_config do |t|
      t.belongs_to  :company, index: true
      t.integer     :long_idle_time #呼叫间隔时长 default: 8s max:12 TODO: min?
      t.boolean     :long_checkin #ture:长签, false:短签（即主动营销和被动营销）TODO: default value? Inform team.
      t.float       :predict_max_ratio #预测式比例上限 default: 2 max: 6 TODO: min?
      t.float       :voice_max_ratio #按键转接和超时转接比例上限 default: 8 max: 30 TODO: min? TODO:SAVE AS HALF 4 . SHOW AS 8
      t.float       :voice_max_duration #超时转接放音时长上限 default: 15s max: 40 TODO: min? 这个在页面上要允许对任务组进行配置。 Inform team.
      t.integer     :keypress_max_concurrency #按键采集最大并发数 default: 100 max: 1000 TODO: min? 验证在CTI端和Web都做，并要防止连续点击。要考虑作为接口发布出去的情况
      # t.time        :voice_start_at #语音营销允许开启时间 default: 08:10 时间外任务自动暂停！不允许企业设置，已经改到系统级设置。
      # t.time        :voice_stop_at #语音营销允许结束时间 default: 19:30
      t.timestamps
    end
  end
end
