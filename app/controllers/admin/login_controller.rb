# Administrator login.
class Admin::LoginController < Admin::BaseController
  skip_before_filter :check_session

  layout 'login'

  def show
    redirect_to redirect_path_for_logged if logged?
  end

  def login
    @_person = @administrator = Administrator.find_by_username(params[:username])

    if @administrator.nil?
      login_failed(t('user.not_exist'))
    else
      unless verify_rucaptcha?(@administrator)
        login_failed(t(:captcha_wrong))
        return
      end

      if @administrator.too_many_wrong_password?
        login_failed(t(:too_many_wrong_password, wrong_password_max_count: Administrator::WRONG_PASSWORD_MAX_COUNT))
        return
      end

      if @administrator.passwd == Digest::SHA1.hexdigest(params[:passwd])
        @administrator.clear_wrong_password_count
        login_success_process
      else
        @administrator.increase_wrong_password_count
        login_failed(@administrator.wrong_password_count >= Administrator::WRONG_PASSWORD_MAX_COUNT ? t(:too_many_wrong_password, wrong_password_max_count: Administrator::WRONG_PASSWORD_MAX_COUNT) : t(:password_wrong_with_count, w: Administrator::WRONG_PASSWORD_MAX_COUNT - @administrator.wrong_password_count))
      end
    end
  end

  def logout
    clear_session

    flash[:notice] = t('success', w: t('logout'))
    redirect_to admin_login_path
  end

  private

  def login_failed(failed_message)
    flash[:error] = failed_message
    flash[:username] = params[:username]
    redirect_to admin_login_path
  end

  def login_success_process
    set_login_session

    flash[:notice] = t('success', w: t('login'))
    redirect_to admin_root_path
  end
end