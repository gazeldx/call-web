# 模块：座席模块
# 表名：禁用座席时, 把座席当前的数据保存在本表中, 用于在下次启用座席时, 直接恢复到之前的状态
class CreateRecoverAgents < ActiveRecord::Migration
  def change
    create_table :recover_agents do |t|
      t.belongs_to  :company, index: true
      t.belongs_to  :agent, index: true
      t.belongs_to  :group # 所在的外呼组id
      t.belongs_to  :salesman
      t.string      :show_number # 主叫号码
      t.string      :group_user_ids # 外呼组当时绑定的管理员ids, 如: 23059,23076,23072
      t.timestamps
    end
  end
end