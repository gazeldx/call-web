class Issue < ActiveRecord::Base
  STATE_NOT_HANDLED = 0
  STATE_HANDLING = 1
  STATE_FINISHED = 3
  STATE_CLOSED = 4

  STATES = [STATE_NOT_HANDLED, STATE_HANDLING, STATE_FINISHED, STATE_CLOSED]

  HANDLER_TYPE_USER = 0
  HANDLER_TYPE_SALESMAN = 1

  CREATOR_TYPE_USER = 0
  CREATOR_TYPE_SALESMAN = 1

  include IssuePerson

  belongs_to :company
  belongs_to :customer

  has_many :issue_items, dependent: :destroy

  validates :company, presence: true
  validates :title, presence: true, uniqueness: { scope: :company_id }
  validates :state, inclusion: { in: STATES }

  def publish_to_handler
    begin
      ::Publisher.publish('UCWebExchange', 'UCWeb.All', { message_key: 'popup_issue',
                                                          issue_id: self.id,
                                                          handler_type: self.handler_type,
                                                          handler_id: self.handler_id }
      ) unless (created_by_self || replied_by_self)
    rescue Exception => e
      return e.message
    end

    ''
  end

  def latest_item
    self.issue_items.order(:id).last
  end

  def handler_type_name
    self.handler_type == HANDLER_TYPE_SALESMAN ? I18n.t(:salesman_) : I18n.t(:user_)
  end

  def creator_type_name
    self.creator_type == HANDLER_TYPE_SALESMAN ? I18n.t(:salesman_) : I18n.t(:user_)
  end

  private

  def created_by_self
    self.creator_id == self.handler_id && self.issue_items.blank?
  end

  def replied_by_self
    if latest_item.present?
      latest_item.creator_id == self.handler_id
    else
      false
    end
  end
end
