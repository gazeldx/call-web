class Point2Policy < Struct.new(:user, :point2)
  attr_reader :user

  def initialize(user, point2)
    @user = user
  end

  def has_ss?
    # @user.have_point(point_name)
  end
end