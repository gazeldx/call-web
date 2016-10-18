class ServerIp < ActiveRecord::Base
  SERVER_TYPE_VOS = 1
  SERVER_TYPE_FREESWITCH = 2
  LOGIN_PASSWD_DEFAULT = 'ccc'

  validates :internal_ip, presence: true, uniqueness: true, format: { with: /\A([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}\z/, message: I18n.t(:invalid_ip_format) }

  validates :port, numericality: { greater_than: 0, less_than: 65535 }

  scope :voses, -> { where(server_type: SERVER_TYPE_VOS) }

  after_initialize :init

  private

  def init
    self.call_type ||= 3
  end
end
