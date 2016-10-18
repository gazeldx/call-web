# 表名：企业配置表
class CreateCompanyConfigs < ActiveRecord::Migration
  def change
    create_table :company_configs do |t|
      t.belongs_to  :company, index: true
      t.boolean     :agent_inbound_level # 座席呼入优先级 ture:开启 false:关闭 default: false
      t.boolean     :vip #(TODO: 这个字段其实目前并没有使用，用的是menus中是否包含ivr.vip来确定权限的。即if policy(:menu2).vip?) ture:开通VIP客户功能, false:不开通VIP客户功能
      t.integer     :popup # [ture: 开启, false: 关闭(default)]
      t.timestamps
    end

    # change_column :company_configs, :popup, 'boolean USING CAST(popup AS boolean)', default: false
    # add_column :company_configs, :export_customers, :boolean, default: false # TODO: 已经不再使用了,用menus中的'cusomter.export'替代了。可以去掉。导入客户信息{true: 可以导, false: 不可以导}
    # add_column :company_configs, :salesman_can_see_numbers, :boolean, default: true # 销售员登录后是否可以看见客户号码
    # add_column :company_configs, :import_customers_count, :integer # 销售线索（客户）数量上限
    # add_column :company_configs, :record_kept_months, :integer, {null: false, default: 3} # 录音被保存的月份数。过期后将被自动删除
    # add_column :company_configs, :obtain_records_limit_ip, :boolean, default: false # 只有经过授权的合法的IP(在valid_ips表中的数据)才可以访问录音(包括录音包)?
    # add_column :company_configs, :switch_salesman, :boolean, default: false # 弹屏后点击保存时, 销售员是否更新成当前销售员?{false: '不更新', true: '更新'}(如果客户没有销售员跟, 无论本值, 都会更新销售员; 如果客户已经有销售员跟了, 本值会起作用。)
  end
end
