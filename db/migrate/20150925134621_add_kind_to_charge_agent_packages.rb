class AddKindToChargeAgentPackages < ActiveRecord::Migration
  def change
    add_column :charge_agent_exceed_free, :kind, :integer # {0:手拔, 1:预测, 2:手拔+预测}
    add_column :charge_agent_minutely, :kind, :integer # {0:手拔, 1:预测, 2:手拔+预测}
    add_column :charge_agent_monthly, :kind, :integer # {0:手拔, 1:预测, 2:手拔+预测}
  end
end