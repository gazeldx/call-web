class CreateIvrs < ActiveRecord::Migration
  def change
    create_table :ivrs do |t|
      t.belongs_to  :company, index: true
      t.string :name                   #
      t.integer :node_id               # 起始节点
      t.integer :ivr_type              # 类型 1-普通ivr; 2-溢出ivr; 3-超时ivr; 4-企业总机；5-企业彩铃；
      t.integer :timeout_length        # 按键超时时长
      t.string :timeout_action         # 按键超时后动作
      t.string :timeout_value          # 按键超时后动作参数
      t.integer :status                # 状态：0-启用；1-禁用
      t.string :remark                 # 备注

      t.timestamps null: false
    end

    #t.integer :timeout_repeat         # 按键超时后重复次数
  end


end
