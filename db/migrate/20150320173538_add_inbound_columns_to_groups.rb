class AddInboundColumnsToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :spill, :boolean #是否走溢出逻辑（如果spill是false，spill_count, play_spill_voice, spill_ivr_id没有意义）
    add_column :groups, :spill_count, :integer #溢出临界数量
    add_column :groups, :play_spill_voice, :boolean #是否播放溢出计数提示录音
    add_column :groups, :spill_ivr_id, :integer

    add_column :groups, :timeout, :boolean #是否走超时逻辑（如果timeout是false，max_loop_times, play_timeout_voice, timeout_ivr_id没有意义）

    add_column :groups, :play_timeout_voice, :boolean
    add_column :groups, :max_loop_times, :integer #超时轮询次数上限，到达后自动拆线
    add_column :groups, :timeout_ivr_id, :integer

    #noagent是已经进入等待队列后才可能放的音，而spill是未进队列前的溢出。
    add_column :groups, :noagent, :boolean #是否走溢出逻辑（如果noagent是false，play_noagent_voice, noagent_ivr_id没有意义）
    add_column :groups, :play_noagent_voice, :boolean #是否播放溢出计数提示录音
    add_column :groups, :noagent_ivr_id, :integer
  end
end
