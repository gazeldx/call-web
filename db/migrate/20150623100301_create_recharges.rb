# 模块：计费模块
# 表名：充值记录表
# 描述：
class CreateRecharges < ActiveRecord::Migration
  def change
    create_table :recharges do |t|
      t.belongs_to  :company, index: true
      t.integer     :operator_id # 操作员
      t.float       :amount # 充值金额
      t.float       :balance # 充值后余额
      t.string      :remark # 备注
      t.timestamp   :created_at # 创建时间
    end
  end
end
