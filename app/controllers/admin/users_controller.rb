class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:change_password, :update_password]

  def change_password
    set_return_to
  end

  def update_password
    @user.update(passwd: Digest::SHA1.hexdigest(params[:user][:passwd]),
                 wrong_password_count: 0)
    flash[:notice] = t(:change_someone_password_success, w: "#{@user.company.name} - #{@user.name}")
    return_to
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
