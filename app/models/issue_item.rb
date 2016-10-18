class IssueItem < ActiveRecord::Base
  include IssuePerson

  belongs_to :issue
  belongs_to :company

  validates :issue, presence: true

  def save_with_issue!(issue)
    self.transaction do
      self.save!

      issue.save!
    end
  end

  def next_item
    self.issue.issue_items.where("id > #{self.id}").order(:id).first
  end

  def state_changed?
    self.state != real_state
  end

  def handler_changed?
    self.handler != real_handler
  end

  def real_state
    if next_item.present?
      next_item.state
    else
      self.issue.state
    end
  end

  def real_handler
    if next_item.present?
      next_item.handler
    else
      self.issue.handler
    end
  end
end
