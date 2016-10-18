class AddResultToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :result, :integer # 1：有意向
  end
end
