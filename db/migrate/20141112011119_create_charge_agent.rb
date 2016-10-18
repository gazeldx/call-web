# 模块：Charge
# 表名：座席计费表
# 描述：
class CreateChargeAgent < ActiveRecord::Migration
  def change
    create_table :charge_agent do |t|
      t.belongs_to  :agent, index: true
      t.integer     :charge_id # 座席套餐id(取自坐席套餐charge_agent_(tables)，值如：1002, 2003, 3001..)，如某座席在该表的charge_id为nil，直接扣企业:charge_company相关balance
      t.float       :min_fee_balance # 呼出保底冻结余额, 和'超出上限不计费'及'共享保底'有关。月初被初始化为:charge_agent_exceed_free.min_fee或:charge_agent_share_minfee.min_fee的值。（当是'charge_agent_exceed_free'时，扣到0后扣企业:balance，并且该值继续扣，直到等于 :min_fee - :max_fee 为止; 当是'charge_agent_share_minfee'时, 不会更新该值, 仅仅是记录设置时的初始值）
      t.integer     :minutes # 剩余分钟数（只和'按分钟数计费'有关。其它都填0。月初被初始化为'按分钟数计费'的:minutes，会不断减少，到0后以'企业呼出套餐'计费，为0时减企业:charge_company的'余额'）
      t.date        :expire_date # 座席有效期。如果到期了，就停用该座席
      t.float       :monthly_rent # 月租（和套餐无关，月初自动扣，扣企业:charge_company的'余额', '企业400呼入包月套餐'送的座席这里为0）
      t.timestamps
    end
  end
end
