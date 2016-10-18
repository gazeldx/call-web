# 模块：CRM
# 表名：功能菜单表与企业管理员关联表
# 描述：企业管理员能够在页面操作哪些菜单通过本表实现
class CreateMenusUsers < ActiveRecord::Migration
  def change
    create_table :menus_users do |t|
      t.belongs_to :menu, index: true
      t.belongs_to :user, index: true
    end
  end
end