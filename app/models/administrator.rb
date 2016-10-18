class Administrator < ActiveRecord::Base
  USERNAME_ADMIN = 'ucadmin'

  WRONG_PASSWORD_MAX_COUNT = 7

  KIND_HELPER = 0
  KIND_TECHNICIAN = 1
  KIND_SELLER = 2
  KIND_OTHER = 3

  has_and_belongs_to_many :points

  validates_length_of :name, within: 2..30
  validates_uniqueness_of :name
  validates_length_of :username, within: 4..25
  validates :username, uniqueness: true, format: { with: /\A[a-z_0-9]+\z/ }
  validates :active, inclusion: { in: [true, false] }

  before_create :encrypt_password

  def admin?
    self.username == USERNAME_ADMIN
  end

  def create_with_relations!(points)
    self.transaction do
      self.save!

      save_points(points)
    end
  end

  def update_points(points)
    self.transaction do
      self.points.delete_all

      save_points(points)
    end
  end

  def have_point(point_name)
    point_names.include?(point_name)
  end

  # TODO: 下面的三个方法可以extract成module。因为user.rb和salesman.rb下也用到了。
  def too_many_wrong_password?
    self.wrong_password_count >= WRONG_PASSWORD_MAX_COUNT
  end

  def increase_wrong_password_count
    self.update(wrong_password_count: self.wrong_password_count + 1)
  end

  def clear_wrong_password_count
    self.update(wrong_password_count: 0)
  end

  private

  def save_points(points)
    points.to_a.each { |point_name| self.points << Point.find_by_name(point_name) }
  end

  def encrypt_password
    self.passwd = Digest::SHA1.hexdigest(self.passwd)
  end

  def point_names
    self.points.map(&:name)
  end
end