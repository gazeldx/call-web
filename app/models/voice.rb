class Voice < ActiveRecord::Base
  mount_uploader :file, VoiceUploader

  belongs_to :company
  belongs_to :checker, class_name: 'Administrator'

  validates :company, presence: true
  validates :name, uniqueness: { scope: :company_id }, length: { in: 1..30 }
  validates :duration, inclusion: 1..180

  def self.get_name(id)
    voice = Voice.where(id: id).first
    voice.nil? ? "语音文件不存在" : voice.name
  end

  def implode
    RedisHelp.del_voice(self.id)
    self.destroy
  end
end
