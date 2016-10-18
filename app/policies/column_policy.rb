class ColumnPolicy
  attr_reader :user, :column

  def initialize(user, column)
    @user = user
    @column = column
  end

  def update?
    workmate?
  end

  private

  def workmate?
    @user.company == @column.company
  end
end