class AddShowNumberToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :show_number, :string # 主叫号码
  end
end