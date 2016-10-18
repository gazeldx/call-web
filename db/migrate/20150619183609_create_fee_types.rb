# 模块：计费模块
# 表名：扣费类型表
# 描述：
class CreateFeeTypes < ActiveRecord::Migration
  def change
    create_table :fee_types do |t|
      t.string     :name # [1: 座席功能费, 2: 号码月租, 3:套餐费, 4:套餐外语音通信费, 5:套餐外短信费, 6:套餐保底冻结, 7:企业保底]
    end
  end
end
