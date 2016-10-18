# 模块：Outbound
# 表明：任务组
class CreateBundles < ActiveRecord::Migration
  def change
    create_table :bundles do |t|
      t.belongs_to :company, index: true
      t.belongs_to :group
      t.belongs_to :number # 这个integer类型的number_id字段已不再使用，用string类型的number替代，详见下文注释
      t.string     :name
      t.float      :ratio
      t.integer    :kind #0:自动呼叫 1:预测呼叫(长签、短签二选1，值为 :company_task_config.long_checkin) 2:按键转接ivr 3:超时转接 4:按键采集(2,3,4是语音营销)
      t.boolean    :active #[true: 启用, false: 已删除]
      t.string     :remark
      t.integer    :creator_id
      t.integer    :manager_id #负责人
      t.integer    :ivr_id #对kind in [2,4]有效
      t.integer    :voice_id #仅对kind = 3有效，超时转接voice
      t.integer    :voice_duration #仅对kind = 3有效，超时转接放音时长。放音一达到该时长就开始转接。该值小于:company_task_config.voice_max_duration
      t.timestamps
    end

    # add_column :bundles, :number, :string # 主叫号码，可以是一个号码或者是用英文逗号分隔的多个号码
  end
end