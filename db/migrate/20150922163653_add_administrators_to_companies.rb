class AddAdministratorsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :seller_id, :integer # UC业务人员(TODO: 现在已经不用了，因为用了nbms维护相关数据了，可以删除)
    add_column :companies, :helper_id, :integer # UC客服人员(TODO: 现在已经不用了，因为用了nbms维护相关数据了，可以删除)
    add_column :companies, :technician_id, :integer # UC技术人员(TODO: 现在已经不用了，因为用了nbms维护相关数据了，可以删除)
  end
end