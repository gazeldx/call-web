class CreateStrategies < ActiveRecord::Migration
  def change
    create_table :strategies do |t|
      t.integer :company_id     # 企业id
      t.integer :group_id       # 策略组id
      t.string :group_name      # 策略组名
      t.string :strategy_type   # 策略类型：inbound-呼入策略；node-节点策略
      t.string :action          # 呼入策略（转ivr,转总机，转彩铃，挂断）Trans_Ivr Trans_Exchange Trans_Coloring Hangup
                                # 节点策略（同节点action一样，转节点，转坐席组等等）"
      t.string :value
      t.string :local       # 地区 例如：0|0512,0513 -不允许0512,0513地区； 1|010,021 -只允许010,021地区的； 空 -允许全部地区
      t.string :allow_date  # 允许日期 2014-03-07,2014-03-08； 空表示允许任何日期
      t.string :not_allow_date  # 不允许日期 2014-03-07,2014-03-08； 空表示允许任何日期
      t.string :week            # 星期 1,2,3,4,5，6,7 表示周一至周日； 空表允许每天
      t.string :time            # 时间段 例 08:30-11:30,13:30-17:30  空表允许任何时间短
      t.integer :level          # 优先级

      #t.timestamps
    end
  end
end
