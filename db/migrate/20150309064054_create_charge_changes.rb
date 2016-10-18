class CreateChargeChanges < ActiveRecord::Migration
  def change
    # 套餐变更表，含下月生效和立刻生效或指定日期生效，以具体时间为准
    #   * 下月生效在月初时更新:charge_agent或:charge_company的相关值
    #   * 目前的逻辑是：变更套餐一律下月生效，初选套餐可选择当月生效或者下月生效
    #   * 不包括‘企业400呼入套餐2’
    #   * 企业套餐不可以取消
    create_table :charge_changes do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :agent, index: true
      t.integer     :charge_id #变更后套餐id
      t.boolean     :processed #true: 变更已成功处理 false:变更尚未处理或处理未成功
      t.timestamp   :effective_at #生效时间
      t.integer     :operator_id #administrator操作员id
      t.string      :remark
      t.float       :min_fee # 保底，仅用于企业
      t.timestamps
    end
  end
end
