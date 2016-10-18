class User::UsersController < ApplicationController
  def change_password
    @user = current_user
  end

  def update_password
    @user = User.find(session[:id])

    if Digest::SHA1.hexdigest(params[:user][:original_password]) != @user.passwd
      flash[:error] = t(:original_password_wrong)
    else
      @user.update_attribute(:passwd, Digest::SHA1.hexdigest(params[:user][:passwd]))

      flash[:notice] = t(:change_password_success)
    end

    redirect_to user_change_password_path
  end
end