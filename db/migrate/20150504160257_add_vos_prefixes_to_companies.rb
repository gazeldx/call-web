class AddVosPrefixesToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :manual_call_prefix, :string, default: '' # 手动外呼前缀
    add_column :companies, :callback_prefix, :string, default: '' # 回呼前缀
    add_column :companies, :task_prefix, :string, default: '' # 任务外呼前缀
  end
end
