class Contact < ActiveRecord::Base
  belongs_to :customer
  belongs_to :salesman
  belongs_to :agent

  validates :customer, presence: true
  # validates :salesman, presence: true
  validates :remark, length: { in: 1..255, message: I18n.t('errors.messages.too_long') }

  def operator_name
    if self.salesman_id.present?
      self.salesman.try(:name)
    elsif self.agent_id.nil?
      I18n.t(:user_)
    else
      self.agent.try(:code)
    end
  end
end