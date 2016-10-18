# 模块：UC后台
# 表名：UC后台功能菜单表
# 描述：与administators关联紧密，管理员能够在后台操作哪些菜单通过关联表实现
class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.string :name
      t.timestamps
    end
  end
end
