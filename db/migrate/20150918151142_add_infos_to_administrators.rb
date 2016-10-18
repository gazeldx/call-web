class AddInfosToAdministrators < ActiveRecord::Migration
  def change
    add_column :administrators, :kind, :integer # 人员类型 {0:客服, 1:技术员, 2:业务员, 3:其它}
    add_column :administrators, :extension, :string # 分机号
    add_column :administrators, :phone, :string # 手机号
    add_column :administrators, :qq, :string # qq号
    add_column :administrators, :weixin, :string # 微信号
    add_column :administrators, :email, :string
  end
end