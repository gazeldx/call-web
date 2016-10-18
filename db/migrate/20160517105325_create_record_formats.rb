# 模块：录音
# 表名：企业自定义本企业的录音格式表
# 描述：将会把name值用“_”连起来。举例：如果某个企业的本表数据有两条，为'calleeNumber'和'date'，则录音格式为: 13966661533_20160517.wav，id值大小代表顺序，id小的在前面
class CreateRecordFormats < ActiveRecord::Migration
  def change
    create_table :record_formats do |t|
      t.belongs_to :company, index: true
      t.string :name # { 'calleeNumber' => '被叫号码', 'callerNumber' => '主叫号码', 'duration' => '通话时长', 'agentCode' => '座席编号(四位数字)', 'salesmanName' => '销售员姓名', 'date' => '录音日期，格式如: 20160517', 'time' => '录音时间，不包含日期，格式如: 142952，表示下午2点29分52秒' }
    end
  end
end
