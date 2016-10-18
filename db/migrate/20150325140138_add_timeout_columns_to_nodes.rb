class AddTimeoutColumnsToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :is_default_timeout, :boolean, default: false
    # true-使用ivr里设置的默认超时设置 ，false-使用node里自定义的设置
    add_column :nodes, :timeout_length, :integer   # 按键超时时长#溢出临界数量
    add_column :nodes, :timeout_action, :string    # 按键超时后动作是否播放溢出计数提示录音
    add_column :nodes, :timeout_value, :string     # 按键超时后动作参数
  end
end
