# 模块：基础模块
# 表名：座席组表
# 描述：把若干个座席放到组里面进行管理，分为呼入组和呼出组。外呼任务由座席组执行
class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      # t.integer     :id #前5位是企业编号，后四位从8001起，以后的自动加1。例：100018001
      t.belongs_to  :company, index: true
      t.string      :name
      t.boolean     :outbound
      t.string      :strategy
      t.integer     :moh_id #等待音的语音文件id，即voice.id ('moh' means 'Music on hold')
      t.integer     :max_wait_time #超时等待时长（20-60s之间，默认30s）
      t.timestamps
    end

    # add_column :groups, :state, :integer, default: 1 # 0: 已删除 1: 正常

    # add_column :groups, :spill, :boolean #是否走溢出逻辑（如果spill是false，spill_count, play_spill_voice, spill_ivr_id没有意义）
    # add_column :groups, :spill_count, :integer #溢出临界数量
    # add_column :groups, :play_spill_voice, :boolean #是否播放溢出计数提示录音
    # add_column :groups, :spill_ivr_id, :integer
    #
    # add_column :groups, :timeout, :boolean #是否走超时逻辑（如果timeout是false，max_loop_times, play_timeout_voice, timeout_ivr_id没有意义）
    #
    # add_column :groups, :play_timeout_voice, :boolean
    # add_column :groups, :max_loop_times, :integer #超时轮询次数上限，到达后自动拆线
    # add_column :groups, :timeout_ivr_id, :integer
    #
    # #noagent是已经进入等待队列后才可能放的音，而spill是未进队列前的溢出。
    # add_column :groups, :noagent, :boolean #是否走溢出逻辑（如果noagent是false，play_noagent_voice, noagent_ivr_id没有意义）
    # add_column :groups, :play_noagent_voice, :boolean #是否播放溢出计数提示录音
    # add_column :groups, :noagent_ivr_id, :integer
  end
end
