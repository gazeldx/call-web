class AddCallTypeToReportAgentDailies < ActiveRecord::Migration
  def change
    add_column :report_agent_dailies, :call_type, :integer # 呼叫类型 {0: 呼出, 1: 呼入}
  end
end