class AddExpireColumnsToPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :expire_at, :timestamp # 过期时间
    add_column :phone_numbers, :validity_hours, :integer # 有效期时长（小时）
  end
end