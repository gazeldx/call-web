# 模块：工单
# 表名：工单回馈表
# 描述：一个工单有多个工单回馈
#      注意：handler_id, handler_type, state保存的是前次的值，本次的值保存在下一个IssueItem中；如果本次是最后一个，则保存在Issue中。
#           这样，使得Issue中的数据始终是最新的，方便搜索。
class CreateIssueItems < ActiveRecord::Migration
  def change
    create_table :issue_items do |t|
      t.belongs_to :issue, index: true
      t.belongs_to :company, index: true
      t.integer :handler_id # 前次的处理者
      t.integer :creator_id
      t.integer :handler_type # 前次的处理者类型{0:User, 1:Salesman}
      t.integer :creator_type
      t.integer :state # 前次的状态{0:尚未受理, 1:受理中, 3:已解决, 4:已关闭}
      t.string :body
      t.string :attachments, array: true, default: []
      t.timestamps
    end
  end
end
