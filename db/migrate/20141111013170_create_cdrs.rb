# 模块：基础模块
# 表名：话单表(CDR: call data record)
# 描述：手拨未接通也记录在本表，其他未接通的记在invalid_cdrs表中
class CreateCdrs < ActiveRecord::Migration
  def change
    create_table :cdrs do |t|
      t.belongs_to  :agent, index: true
      t.belongs_to  :salesman, index: true
      t.belongs_to  :company
      t.belongs_to  :task
      t.timestamp   :start_stamp #发起呼叫时间
      t.string      :callee_number #被叫号码
      t.string      :caller_number #主叫号码
      t.timestamp   :end_stamp #通话结束时间
      t.timestamp   :answer_stamp #应答时间
      t.integer     :duration #持续时长，单位：秒
      t.float       :cost #费用
      t.integer     :call_type #呼叫类型 [0: 任务, 1: 呼入, 2: 手动外呼, 3: 呼转, 4: 点击呼叫, 5: API调用的外呼]
      t.integer     :result #0:接通成功 1-6的值请参考invalid_cdrs表的kind字段（非任务外呼用到）
      t.integer     :hangup_flag #挂断方
      t.string      :hangup_cause #挂断原因
      t.string      :record_url #录音地址
      t.string      :digits_dialed #按了什么键，如‘01#’
      t.integer     :charge_id #套餐id(这个是座席或企业的套餐混在一起)
      t.timestamp   :created_at #TODO: 貌似这个字段无用
    end

    add_index :cdrs, [:company_id, :start_stamp]

    # t.change :id, :string # 从freeSWITCH的event_socket中返回的UUID值
    # add_column :cdrs, :bridge_stamp, :timestamp # 桥接时间
    # add_column :cdrs, :group_id, :integer # 目前仅用于记录呼入时所转到的队列id
    # add_column :cdrs, :app_call_id, :string #返回给APP用的唯一ID,APP会用该值查询单条话单
  end
end






