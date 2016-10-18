# 模块：计费模块
# 表名：保底冻结记录表
# 描述：TODO: 这个表需要移除，目前已经不再使用，已经合并到bills表了
class CreateFreezes < ActiveRecord::Migration
  def change
    create_table :freezes do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :agent, index: true
      t.integer     :charge_id # 套餐编号
      t.float       :fee # 保底冻结的金额
      t.float       :balance # 余额
      t.string      :remark # 备注
      t.timestamp   :created_at # 创建时间
    end
  end
end
