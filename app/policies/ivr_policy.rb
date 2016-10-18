class IvrPolicy
  attr_reader :user, :ivr

  def initialize(user, ivr)
    @user = user
    @ivr = ivr
  end

  def update?
    workmate?
  end

  private

  def workmate?
    @user.company == @ivr.company
  end
end