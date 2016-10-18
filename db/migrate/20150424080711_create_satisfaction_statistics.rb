class CreateSatisfactionStatistics < ActiveRecord::Migration
  def change
    create_table :satisfaction_statistics do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :salesmen, index: true
      t.string :cdr_id
      t.string :customer_number
      t.string :value
      t.datetime :create_at

      #t.timestamps
    end

    # add_column :satisfaction_statistics, :agent_id, :integer # 座席id
  end
end
