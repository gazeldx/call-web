# 模块：CRM
# 表名：销售员表
class CreateSalesmen < ActiveRecord::Migration
  def change
    create_table :salesmen do |t|
      t.string      :username #登陆账号名
      t.belongs_to  :company, index: true
      t.string      :name #姓名
      t.string      :passwd
      t.timestamps
    end

    add_index :salesmen, :username

    # add_column :salesmen, :active, :boolean, default: true # {true: 启用, false: 停用}
    # add_column :salesmen, :team_id, :integer # 在20150605113129_add_team_id_to_salesmen.rb中加入
    # add_column :salesmen, :wrong_password_count, :integer, default: 0 # 密码输入错误次数
  end
end