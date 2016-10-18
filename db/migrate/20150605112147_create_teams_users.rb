# 模块：CRM
# 表名：team与user对应关系表
class CreateTeamsUsers < ActiveRecord::Migration
  def change
    create_table :teams_users do |t|
      t.belongs_to :user, index: true
      t.belongs_to :team, index: true
    end
  end
end
