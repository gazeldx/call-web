# 模块：Outbound
# 表明：任务号码池
class CreateTaskPhones < ActiveRecord::Migration
  def change
    create_table :task_phones do |t|
      t.belongs_to :task, index: true
      t.string     :phone
      # t.timestamp  :created_at
    end
  end
end
