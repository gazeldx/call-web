class RecordPackage < ActiveRecord::Base
  MAX_TIMES_EVERYDAY = 20 # 每天录音打包的最多次数

  belongs_to :company

  def creator
    User.find(self.creator_id)
  end

  def package_file_name
    "#{self.company_id}/#{self.id}.tar.gz"
  end

  def package_url
    if self.created_at < DateTime.parse("2016-06-06")
      "http://#{Settings.ucweb.domain}:#{Settings.ucweb.port}/record/packages/#{package_file_name}"
    else
      "http://#{Settings.ucweb.domain}:#{Settings.ucweb.port}/#{package_file_name}"
    end
  end
end
