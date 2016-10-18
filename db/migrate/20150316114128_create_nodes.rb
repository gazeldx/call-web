class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.integer :ivr_id
      t.string :name
      t.string :from_digits     
      t.string :action
      t.string :value
        # value字段保存的对象根据action字段的不同也会相应变化
        #  action            value             动作描述
        # "Trans_Node"    => 节点id nodes表id   =>  '转节点';
        # "Parent_Node"   => 父节点id nodes表id   => '返回上一层';
        # "Voice"         => 语音 voices表id   => '播放语音';
        # "Trans_Group"   => 座席组 groups表id   =>'转组';
        # "Replay"        => 无     =>'重听';
        # "Hangup"        => 挂断语音voice表id   =>'挂断';
        # "Strategy"      => 尚未支持   =>'转策略';
        # "Outbound"      => 尚未支持   =>'外部号码';
        # "Agent"         => 尚未支持   =>'转座席';
        # "Extension"     => 分机号 extension_configs表的extension   =>'转分机';
        # "Report_Number" => 尚未支持  =>'报号功能';
        # "Continue"      => 无   =>'继续等待';
        # "Rate"          => 评价结果{ "0" => "投诉", "1" => "非常满意", "2" => "满意", "3" => "一般", "4" => "不满意", "5" => "非常不满意" }   =>'评价';
        # "Complain"      => 投诉处理组 groups表id   =>'投诉'
      t.integer :parent_id
      t.string :patriline
      t.string :remark



      
      
      t.timestamps null: false
    end
  end
end
