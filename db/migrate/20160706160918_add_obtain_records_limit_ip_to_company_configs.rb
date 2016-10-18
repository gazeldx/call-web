class AddObtainRecordsLimitIpToCompanyConfigs < ActiveRecord::Migration
  def change
    add_column :company_configs, :obtain_records_limit_ip, :boolean, default: false # 只有经过授权的合法的IP(在valid_ips表中的数据)才可以访问录音(包括录音包)?
  end
end