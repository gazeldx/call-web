class Cdr < ActiveRecord::Base
  include ActionView::Helpers
  include CdrBase

  CALL_TYPE_TASK = 0
  CALL_TYPE_INBOUND = 1
  CALL_TYPE_MANUAL = 2
  CALL_TYPE_TRANSFER = 3
  CALL_TYPE_CLICK = 4
  CALL_TYPE_API = 5

  CALL_TYPES = [CALL_TYPE_TASK, CALL_TYPE_MANUAL, CALL_TYPE_INBOUND, CALL_TYPE_TRANSFER, CALL_TYPE_CLICK, CALL_TYPE_API]

  MAX_PACKAGE_RECORDS_CDRS_COUNT = 500 # 系统忙时段可打包的最大录音数量
  MAX_PACKAGE_RECORDS_CDRS_COUNT_FREE_TIME = 1000 # 系统空闲时段可打包的最大录音数量

  MAX_EXPORT_COUNT_ON_BUSY_TIME = 1000 # 工作时间可以导出的话单最大数量

  belongs_to :company
  belongs_to :agent
  belongs_to :task
  belongs_to :salesman
  belongs_to :group

  # 已经合成过, 直接可听的录音。返回值示例: [["/sharedfs/record/record3031/67034/e3764efe-9419-11e5-ae0d-f171cefbc6d1.mp3", "13956011244_20151126_164421_1009"], ["/sharedfs/record/record32/60065/c90fab3c-9419-11e5-a44f-c338ecb7ad15.mp3", "15866298216_20151126_164337_1009"]]
  def self.records_map(cdrs)
    cdrs.reject { |cdr| cdr.record_url.empty? || !(cdr.record_url.end_with?('.wav') || cdr.record_url.end_with?('.mp3')) }.map do |cdr|
      [cdr.record_url, cdr.record_filename]
    end
  end

  # 未合成的录音。返回值示例: [["/sharedfs/record/record3031/67034/e3764efe-9419-11e5-ae0d-f171cefbc6d1", "13956011244_20151126_164421_1009", "e3764efe-9419-11e5-ae0d-f171cefbc6d1"], ["/sharedfs/record/record32/60065/c90fab3c-9419-11e5-a44f-c338ecb7ad15", "15866298216_20151126_164337_1009", "c90fab3c-9419-11e5-a44f-c338ecb7ad15"]]
  def self.raw_records_map(cdrs)
    cdrs.reject { |cdr| cdr.record_url.empty? || (cdr.record_url.end_with?('.wav') || cdr.record_url.end_with?('.mp3')) }.map do |cdr|
      [cdr.record_url, cdr.id]
    end
  end

  def self.handle_dup_record_name(records_map)
    filenames = records_map.map { |record| record[1] }
    records_map.map do |record|
      [record[0], filenames.count(record[1]) >= 2 ? "#{record[1]}_#{rand(99999)}" : record[1]] # 重名录音加后缀区分开
    end
  end
end
