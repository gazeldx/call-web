# 模块：CRM
# 表名：功能菜单表与企业关联表
# 描述：企业能拥有哪些菜单通过本表实现
class CreateCompaniesMenus < ActiveRecord::Migration
  def change
    create_table :companies_menus do |t|
      t.belongs_to :company, index: true
      t.belongs_to :menu, index: true
    end
  end
end
