# 模块：Outbound
# 描述：任务，会关联到一个号码池
class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.belongs_to :bundle
      t.string     :name
      t.integer    :state # { 9: init(允许从csv文件导入号码), 0: not started, 1:running, 2:paused, 3:finished, 5:stashed (各状态的关系变化只有以下几种：9 => 0; 0 => 1; 1 => 2 or 3; 2 => 1; 0 or 2 or 9 => 5) }
      t.timestamp  :started_at
      t.timestamp  :stopped_at
      t.integer    :phone_count #号码总数
      t.integer    :executed_count #已执行数量
      t.integer    :contacted_count #接通数
      t.string     :remark
      t.integer    :creator_id
      t.timestamps

      # add_column :tasks, :answered_count, :integer #应答数量
      # add_column :tasks, :missed_count, :integer #呼损数量
    end
  end
end