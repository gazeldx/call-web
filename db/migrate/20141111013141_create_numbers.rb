# 模块：CTI
# 呼入号码表
class CreateNumbers < ActiveRecord::Migration
  def change
    create_table :numbers do |t|
      t.belongs_to  :company, index: true
      t.string      :number
      t.boolean     :for_task #是否是任务外显（已删除）
      t.boolean     :for_agent #是否是坐席外显（已删除）
      t.boolean     :inbound #是否是呼入（已删除）
      t.integer     :used_count #使用次数（已删除）
      t.boolean     :from_company #是否是企业提供的？ true: 企业提供 false: 系统提供（已删除）
      # t.date        :start_date #启用日期
      t.date        :expire_date #过期日期（已删除）
      t.integer     :creator_id
      t.timestamps
    end
  end

  # add_column :numbers, :inbound_max_lines, :integer

  # remove_column :numbers, :for_task
  # remove_column :numbers, :for_agent
  # remove_column :numbers, :inbound
  # remove_column :numbers, :used_count
  # remove_column :numbers, :from_company
  # remove_column :numbers, :expire_date
end