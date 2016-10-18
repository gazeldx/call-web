# 模块：基础
# 表名：企业管理员表与座席组的关联表
# 描述：企业管理员能够管理哪些座席组通过本表实现
class CreateGroupsUsers < ActiveRecord::Migration
  def change
    create_table :groups_users do |t|
      t.belongs_to :user, index: true
      t.belongs_to :group, index: true
    end
  end
end
