class CompanyPolicy
  attr_reader :user, :company

  def initialize(user, company)
    @user = user
    @company = company
  end

  def create_bundle?
    workmate? && @company.task_config.present? && @company.outbound_groups.any? && @company.bundles.count_by_kind(@company.bundle_kind) < max_bundles
  end

  def view_bills?
    workmate? && @company.charge_company.present?
  end

  def workmate?
    @user.company == @company
  end

  def start_vacuum?
    @user.is_a?(Administrator) && @user.admin?
  end

  private

  def max_bundles
    (@company.agents.ok.count / 70 + 1) * 10 # 每达到70个座席就可以多创建10个外呼任务
  end
end