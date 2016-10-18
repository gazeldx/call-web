# TODO: 我可以做一个权限限定，如果企业包含任务功能，无法选中手拨150包月。
class Admin::ChargeAgentController < Admin::BaseController
  def edit
    @charge_agent = ChargeAgent.find_by_agent_id(params[:id])
    set_return_to
  end

  def update
    # TODO: Authorize.
    @charge_agent = ChargeAgent.find_by_agent_id(params[:id])

    if balance_not_enough?
      flash[:error] = t('company.balance_not_enough', w: min_balance_for_this_charge.round(2))
      return_to
    else
      @charge_agent.create_charge!(charge_agent_params)

      flash[:notice] = t('charge_agent.set_success', w: @charge_agent.agent.code)
      return_to
    end
  end

  def update_monthly_rent
    @charge_agent = ChargeAgent.find_by_agent_id(params[:id])

    if @charge_agent.should_charge_monthly_rent?(charge_agent_params[:monthly_rent].to_f) && balance_not_enough_for_update_monthly_rent?
      flash[:error] = t('company.balance_not_enough', w: min_balance_for_update_monthly_rent.round(2))
      return_to
    else
      @charge_agent.update_monthly_rent!(charge_agent_params[:monthly_rent].to_f)

      flash[:notice] = t('charge_agent.monthly_rent_updated_success', w: @charge_agent.agent.code)
      return_to
    end
  end

  private

  def balance_not_enough?
    @charge_agent.agent.company.charge_company.balance <= min_balance_for_this_charge
  end

  def min_balance_for_this_charge
    ChargeAgent.charge_fee(charge_agent_params[:charge_id], @charge_agent.agent.company_id) + (charge_agent_params[:monthly_rent].to_f * DateTime.left_days_this_month_ratio)
  end

  def balance_not_enough_for_update_monthly_rent?
    @charge_agent.agent.company.charge_company.balance <= min_balance_for_update_monthly_rent
  end

  def min_balance_for_update_monthly_rent
    charge_agent_params[:monthly_rent].to_f * DateTime.left_days_this_month_ratio
  end

  def charge_agent_params
    params.require(:charge_agent).permit(:charge_id, :monthly_rent)
  end
end
