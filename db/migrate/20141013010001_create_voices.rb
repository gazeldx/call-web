# 模块：基础模块
# 表名：语音表
# 描述：语音可用于IVR等
class CreateVoices < ActiveRecord::Migration
  def change
    create_table :voices do |t|
      t.belongs_to  :company, index: true
      t.string      :name
      t.string      :file #语音文件path
      t.integer     :duration #语音时长，单位秒
      t.integer     :checker_id #审核人
      t.timestamps
    end
  end
end

