class User < ActiveRecord::Base
  WRONG_PASSWORD_MAX_COUNT = 7

  belongs_to :company

  has_and_belongs_to_many :menus
  has_and_belongs_to_many :groups # 在下面还定义了method groups_ , 实际常用的是groups_
  has_and_belongs_to_many :teams # 在下面还定义了method teams_ , 实际常用的是teams_

  attr_accessor :administrator # TODO: 这两行没有用到, 应该被清理掉。本来是想用于"如果是统一管理员在后台以管理员的身份登录到企业中, 则这里的administrator对应的是统一管理员对象"的, 后来用session[:administrator_id]代替了
  alias :administrator? :administrator

  validates           :username, uniqueness: true
  validates_length_of :username, within: 4..16
  validates_format_of :username, with: /\A[a-z_0-9]+\z/, message: I18n.t('invalid_format')# TODO: TEST NOT A-Z START.

  validates_length_of :name, within: 2..30
  validates           :name, uniqueness: { scope: :company_id }
  validates :active, inclusion: { in: [true, false] }
  validates :company, presence: true

  before_create :encrypt_password

  after_initialize :init

  def teams_
    if admin?
      self.company.teams
    else
      self.teams
    end
  end

  def groups_
    if admin?
      self.company.groups
    else
      self.groups
    end
  end

  def agents
    if admin?
      self.company.agents.ok
    else
      Agent.ok.where(id: AgentsGroups.where(group_id: self.groups.state_ok.pluck(:id)).pluck(:agent_id))
    end
  end

  def customers
    if admin?
      self.company.customers.ok
    else
      self.company.customers.ok.where(salesman_id: Salesman.where(team_id: self.teams.pluck(:id)).pluck(:id))
    end
  end

  def cdrs
    if admin?
      self.company.cdrs
    else
      self.company.cdrs.where(salesman_id: Salesman.where(team_id: self.teams.pluck(:id)).pluck(:id))
    end
  end

  def history_cdrs
    if admin?
      self.company.history_cdrs
    else
      self.company.history_cdrs.where(salesman_id: Salesman.where(team_id: self.teams.pluck(:id)).pluck(:id))
    end
  end

  def invalid_cdrs
    if admin?
      self.company.invalid_cdrs
    else
      self.company.invalid_cdrs.where(task_id: Task.where(bundle_id: Bundle.where(group_id: self.groups.state_ok.pluck(:id)).pluck(:id)).pluck(:id))
    end
  end

  def salesmen
    if admin?
      self.company.salesmen.order(:name)
    else
      Salesman.where(team_id: self.teams.pluck(:id)).order(:name)
    end
  end

  def report_agent_dailies
    if admin?
      self.company.report_agent_dailies
    else
      self.company.report_agent_dailies.where(salesman_id: Salesman.where(team_id: self.teams.pluck(:id)).pluck(:id))
    end
  end

  def bundles
    if admin?
      self.company.bundles
    else
      self.company.bundles.where(group_id: self.groups.pluck(:id))
    end
  end

  def tasks
    Task.where(bundle_id: self.bundles.pluck(:id))
  end

  def outbound_groups
    if admin?
      self.company.outbound_groups
    else
      self.groups.outbound.order('created_at')
    end
  end

  def init
    self.active = true if self.active.nil?
  end

  def admin?
    self == self.company.admin
  end

  def create_with_relations!(menus)
    self.transaction do
      self.save!

      save_menus(menus)
    end
  end

  def update_menus(menus)
    self.transaction do
      self.menus.delete_all

      save_menus(menus)
    end
  end

  def limited_menus
    if self.admin?
      self.company.menus
    else
      self.company.menus & (self.menus + [Menu.find_by_name('issue.management')]) # issue.management菜单目前对所有企业对可见,销售员也可用,以后要把这个特殊处理去掉
    end
  end

  def have_menu?(menu_name)
    self.company.menus.map(&:name).include?(menu_name) && (admin? || self.menus.map(&:name).include?(menu_name))
  end

  def manage_many_teams?
    self.company.teams.count > 1 && (self.admin? || self.teams.count > 1)
  end

  def too_many_wrong_password?
    self.wrong_password_count >= WRONG_PASSWORD_MAX_COUNT
  end

  def increase_wrong_password_count
    self.update(wrong_password_count: self.wrong_password_count + 1)
  end

  def clear_wrong_password_count
    self.update(wrong_password_count: 0)
  end

  # 在导入客户时, 自动创建的, 隐藏的, 与本管理员唯一匹配的销售员。
  def self_salesman
    Salesman.find_by_name("#{Salesman::USER_UNIQUE_PREFIX}#{self.id}")
  end

  private

  def save_menus(menus)
    menus.each { |menu_name| self.menus << Menu.find_by_name(menu_name) }
  end

  def encrypt_password
    self.passwd = Digest::SHA1.hexdigest(self.passwd)
  end
end
