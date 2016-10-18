# 模块：工单
# 表名：工单表
# 描述：
class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.belongs_to :company, index: true
      t.belongs_to :customer
      t.integer :handler_id # 当前处理者
      t.integer :creator_id
      t.integer :handler_type # {0:User, 1:Salesman}
      t.integer :creator_type # {0:User, 1:Salesman}
      t.integer :state # {0:尚未受理, 1:受理中, 3:已解决, 4:已关闭}
      t.string :title
      t.string :body
      t.string :attachments, array: true, default: []
      t.timestamps
    end
  end
end
