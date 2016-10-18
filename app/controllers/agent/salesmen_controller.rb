class Agent::SalesmenController < SalesmanBaseController
  def change_password
    @salesman = current_user
  end

  def update_password
    @salesman = Salesman.find(session[:id])

    if Digest::SHA1.hexdigest(params[:salesman][:original_password]) != @salesman.passwd
      flash[:error] = t(:original_password_wrong)
    else
      @salesman.update_attribute(:passwd, Digest::SHA1.hexdigest(params[:salesman][:passwd]))

      flash[:notice] = t(:change_password_success)
    end

    redirect_to change_password_path
  end
end
