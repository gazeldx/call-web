# 模块：计费模块
# 表名：账单表
# 描述：
class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :agent, index: true
      t.integer     :fee_type_id # 扣费类型，值引用自fee_types表的id [1: 座席功能费, 2: 号码月租, 3: 套餐费, 4: 套餐外语音通信费, 5:套餐外短信费, 6: 套餐保底冻结, 7: 企业保底]
      t.integer     :charge_id # 套餐编号
      t.float       :fee # 费用
      t.float       :balance # 扣完费用后的余额
      t.float       :min_fee_balance # 冻结保底余额
      t.integer     :month # 结算年月，填 201506 这样的数值
      t.string      :remark # 备注
      t.timestamp   :created_at # 创建时间
    end
  end
end
