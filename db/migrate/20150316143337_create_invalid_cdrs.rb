# 模块：CTI
class CreateInvalidCdrs < ActiveRecord::Migration
  def change
    # 无效话单
    create_table :invalid_cdrs do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :task
      t.timestamp   :start_stamp #发起呼叫时间
      t.string      :callee_number #被叫号码
      t.string      :caller_number #主叫号码
      t.integer     :kind #1:空号 2:停机 3:关机 4:无法接通（信号不好） 5:主动挂断拒接 6:无应答
    end
  end
end
