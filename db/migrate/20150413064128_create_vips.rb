class CreateVips < ActiveRecord::Migration
  def change
    create_table :vips do |t|
      t.belongs_to  :company, index: true
      t.string :name   # 策略组名
      t.string :action # 转接动作（转ivr，转总机，转彩铃，转策略，挂断）Trans_Ivr Trans_Exchange Trans_Coloring Trans_Strategy Hangup
      t.string :value
      t.boolean :status, null: false, default: false   # 状态  true-启用
      #t.timestamps
    end
  end
end