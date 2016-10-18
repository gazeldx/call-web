# 模块：CTI
# 主叫号码表(数据是从号码管理系统中同步过来的)
class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.belongs_to  :company, index: true
      t.string      :number
      t.boolean     :for_task #是否是任务外显
      t.boolean     :for_agent #是否是座席外显
      t.timestamps
    end
  end
end