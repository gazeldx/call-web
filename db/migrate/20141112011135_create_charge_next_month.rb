# 模块：Charge(注意：本表已经被删除!替代它的是 20150309064054_create_charge_changes.rb)
class CreateChargeNextMonth < ActiveRecord::Migration
  def change
    # 变更套餐次月生效表(注意：本表已经被删除!)
    #   * 目的就是在月初时更新:charge_agent或:charge_company的相关值
    #   * 变更套餐一律下月生效，初选套餐可选择当月生效或者下月生效
    #   * 不包括‘企业400呼入套餐2’
    #   * 如果要取消套餐，可以将:charge_id设置为nil
    create_table :charge_next_month do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :agent, index: true
      t.integer     :charge_id #变更后套餐id
      t.timestamps
    end
  end
end