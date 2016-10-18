class AddWrongPasswordCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wrong_password_count, :integer, default: 0 # 密码输入错误次数
  end
end