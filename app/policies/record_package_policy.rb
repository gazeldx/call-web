class RecordPackagePolicy
  attr_reader :user, :record_package

  def initialize(user, record_package)
    @user = user
    @record_package = record_package
  end

  def update?
    workmate? && (@user.admin? || @user.id == record_package.creator_id)
  end

  private

  def workmate?
    @user.company == @record_package.company
  end
end