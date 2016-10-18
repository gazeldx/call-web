# 模块：录音
# 表名：录音包表
# 描述：
class CreateRecordPackages < ActiveRecord::Migration
  def change
    create_table :record_packages do |t|
      t.belongs_to :company, index: true
      t.integer :creator_id
      t.string :title
      t.timestamps
    end
  end
end
