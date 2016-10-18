# 模块：UC后台
# 表名：UC后台功能菜单与UC管理员关联表
# 描述：UC管理员能够在UC后台操作哪些菜单通过本表实现
class CreateAdministratorsPoints < ActiveRecord::Migration
  def change
    create_table :administrators_points do |t|
      t.belongs_to :administrator, index: true
      t.belongs_to :point, index: true
    end
  end
end