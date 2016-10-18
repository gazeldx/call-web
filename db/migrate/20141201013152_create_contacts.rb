# 模块：CRM
#   客户联络记录
#     1.弹屏时添加；
#     2.销售员手工添加(这种情况agent_id, task_id...等数据是nil)
class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string     :remark #联络小结
      t.belongs_to :customer, index: true
      t.belongs_to :company # TODO: 这里以后可能要加索引，因为目前在管理员中加入了查询
      t.belongs_to :salesman # TODO: 这里以后可能要加索引，因为目前在销售员中加入了查询
      t.belongs_to :agent
      t.belongs_to :task
      t.belongs_to :cdr
      t.integer    :call_type #取自cdrs表里的call_type
      t.string     :phone #客户号码
      t.timestamps
    end

    # t.change :cdr_id, :string
    # add_column :contacts, :result, :integer # 1：有意向
  end
end