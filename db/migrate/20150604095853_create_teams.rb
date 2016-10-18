# 模块：基础模块
# 表名：销售员组表
# 描述：把若干销售员放到组里面进行管理
class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.belongs_to  :company, index: true
      t.string      :name
      t.timestamps
    end
  end
end
