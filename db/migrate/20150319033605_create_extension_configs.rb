class CreateExtensionConfigs < ActiveRecord::Migration
  def change
    create_table :extension_configs do |t|
      t.belongs_to  :company, index: true
      t.string :extension          #分机号
      t.integer :extension_type    #分机类型；0-坐席组；1-坐席
      t.integer :group_id
      t.integer :agent_id

      #t.timestamps
    end
  end
end
