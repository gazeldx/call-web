# 模块：基础模块
# 表名：企业表
class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      # t.integer  :id #企业编号，五位数字
      t.string   :name
      t.integer  :license #座席许可数
      t.boolean  :active # 本字段已经不再使用, 已经在后续的migration中被remove_column掉了。替代本字段的是:state, 详见下方
      t.string   :mobile
      t.integer  :manual_call_vos_id #手动外呼VOS id :server_ips.vos.id
      t.integer  :callback_vos_id #回呼VOS id :server_ips.vos.id
      t.integer  :task_vos_id #任务外呼VOS id :server_ips.vos.id
      t.timestamps
    end

    # add_column :companies, :manual_call_prefix, :string, default: '' # 手动外呼前缀
    # add_column :companies, :callback_prefix, :string, default: '' # 回呼前缀
    # add_column :companies, :task_prefix, :string, default: '' # 任务外呼前缀

    # add_column :companies, :state, :integer, default: 1 # {1: 正常, 2: 申请下线, 3: 申请下线审核通过}
    # remove_column :companies, :active # 用state后, :active字段不再使用

    # add_column :companies, :seller_id, :integer # UC业务人员(TODO: 现在已经不用了，因为用了nbms维护相关数据了，可以删除)
    # add_column :companies, :helper_id, :integer # UC客服人员(TODO: 现在已经不用了，因为用了nbms维护相关数据了，可以删除)
    # add_column :companies, :technician_id, :integer # UC技术人员(TODO: 现在已经不用了，因为用了nbms维护相关数据了，可以删除)
  end
end