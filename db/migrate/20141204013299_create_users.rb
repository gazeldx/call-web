# 模块：CRM
# 表名：企业管理员表
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string     :username
      t.belongs_to :company, index: true
      t.string     :name
      t.string     :passwd
      t.boolean    :active # {true: 启用, false: 停用}
      t.timestamps
    end

    add_index :users, :username

    # add_column :users, :wrong_password_count, :integer, default: 0 # 密码输入错误次数
  end
end
