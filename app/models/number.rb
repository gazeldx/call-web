class Number < ActiveRecord::Base
  belongs_to :company

  has_one :inbound_config, foreign_key: 'inbound_number_id'

  validates_length_of :number, within: 5..15
  validates_uniqueness_of :number
  validates :number, numericality: { greater_than_or_equal_to: 0 }

  # after_initialize :init
  # after_validation :set_inbound

  # scope :task_numbers, -> { where(for_task: true).where(['from_company = false OR expire_date >= ?', Date.today]) }
  #
  # scope :agent_numbers, -> { where(for_agent: true).where(['from_company = false OR expire_date >= ?', Date.today]) }

  def self.get_number(id)
    number = Number.where(id: id).first
    number.nil? ? "号码不存在" : number.number
  end

  def create_with_inbound_configs!(inbound_max_lines)
    self.transaction do
      self.save!

      InboundConfig.create!({ company_id: self.company_id,
                              inbound_number_id: self.id,
                              max_inbound: inbound_max_lines,
                              config_type: InboundConfig::CONFIG_TYPE_NOT_SET
                            }) if self.company_id.present?
    end

    RedisHelp.add_inbound_number(self.inbound_config) if self.company_id.present?
  end

  def inbound_max_lines
    self.inbound_config.try(:max_inbound)
  end

  private

  # def init
  #   self.used_count ||= 0
  # end

  # def set_inbound
  #   self.inbound = false if (self.for_task? && self.from_company?)
  #   self.inbound = false if (self.for_agent? && self.from_company?)
  # end

end
