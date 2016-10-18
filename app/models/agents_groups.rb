class AgentsGroups < ActiveRecord::Base
  LEVEL_HIGH = 3
  LEVEL_MEDIUM = 2
  LEVEL_LOW = 1

  belongs_to :agent
  belongs_to :group

  validates :group, presence: true
  validates :agent, presence: true

  after_initialize :init

  def level_as_word
    case self.level
      when LEVEL_LOW then 'low'
      when LEVEL_HIGH then 'high'
      else 'medium'
    end
  end

  private

  def init
    self.level ||= LEVEL_MEDIUM unless self.group.outbound?
  end
end
