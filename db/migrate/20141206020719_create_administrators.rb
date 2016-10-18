# 模块：UC后台
# 表名：UC管理员表
class CreateAdministrators < ActiveRecord::Migration
  def change
    create_table :administrators do |t|
      t.string :username
      t.string :name
      t.string :passwd
      t.timestamps
    end

    add_index :administrators, :username

    # add_column :administrators, :active, :boolean, default: true # {true: 启用, false: 停用}
    # add_column :administrators, :kind, :integer # 人员类型 {0:客服, 1:技术员, 2:业务员, 3:其它}
    # add_column :administrators, :extension, :string # 分机号
    # add_column :administrators, :mobile, :string # 手机号
    # add_column :administrators, :qq, :string # qq号
    # add_column :administrators, :weixin, :string # 微信号
    # add_column :administrators, :email, :string
    # add_column :administrators, :wrong_password_count, :integer, default: 0 # 密码输入错误次数
  end
end
