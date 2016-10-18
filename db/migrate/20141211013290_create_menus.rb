# 模块：CRM
# 表名：企业功能菜单表
# 描述：与 1、companies关联紧密，企业拥有那些菜单功能
#        2、users, 企业管理员能够在页面操作哪些菜单通过关联表实现
class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.string :name
      t.timestamps
    end
  end
end
