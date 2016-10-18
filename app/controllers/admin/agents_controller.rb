class Admin::AgentsController < Admin::BaseController
  before_action :set_agent, only: [:edit, :update, :destroy, :enable, :disable_eom]
  before_action :set_company, only: [:index]

  def index
    # TODO: 日志显示有几个表没有eager loading, 可以考虑优化下
    @agents = @company.agents.includes(:salesman, :groups, :extensions, :charge_changes).page(params[:page]).order('id DESC')
  end

  def edit
    set_return_to
  end

  def update
    original_contact_number = @agent.contact_number

    if @agent.update(agent_params)
      RedisHelp.update_agent_contact(@agent, original_contact_number)

      flash[:notice] = t('agent.updated')
      return_to
    else
      render :edit
    end
  end

  # 座席月底禁用
  def disable_eom
    authorize @agent

    DisabledAgent.create!(company_id: @agent.company_id, agent_id: @agent.id)

    flash[:notice] = t('agent.disabled_eom')
    redirect_to request.referer
  end

  # 禁用一个座席
  def destroy
    authorize @agent

    min_fee_balance = ChargeAgent.get_class_name_by_charge_id(@agent.charge_agent.charge_id) == ChargeAgentShareMinfee ? @agent.charge_agent.min_fee_balance : 0

    disable_agent

    if flash[:error].blank? && min_fee_balance > 0
      RedisHelp.deduct_share_fee_when_disable_agent(@agent.company_id, min_fee_balance)
    end

    redirect_to request.referer
  end

  # 在月初时, UC管理员用本方法真正禁用掉这些"月底禁用座席".
  def disable_eom_agents
    if current_user.admin?
      DisabledAgent.where(processed: true).offset(rand(DisabledAgent.where(processed: true).count)).limit(100).each_with_index do |disabled_agent|
        if policy(disabled_agent.agent).destroy?
          @agent = disabled_agent.agent
          flash[:error], flash[:notice] = nil, nil

          disable_agent
        end
      end
    end

    redirect_to request.referer, notice: '已禁用！'
  end

  def enable
    authorize @agent

    @agent.enable
    @agent.recover

    flash[:notice] = t('agent.enabled', w: @agent.code)
    redirect_to request.referer
  end

  def switch_agents_options
    company = Company.find(params[:company_id])

    options = company.agents.ok.order(:id).map do |option|
      "<option value='#{option.id}'>#{option.id}</option>"
    end.join(',')

    render json: { result: options }
  end

  private

  def agent_params
    params.require(:agent).permit(:transfer, :private_phone)
  end

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def check_agent_state_in_groups
    @agent.groups.each do |group|
      if RedisHelp.busying?(group, @agent)
        flash[:error] = "本次操作被系统拒绝处理，原因是“您正在禁用的座席#{@agent.id}正处于通话忙碌状态。”"
        break
      end
    end
  end

  def check_agent_groups_members
    @agent.groups.each do |group|
      if group.agents.count <= 1 && group.cannot_destroy_reason.present?
        flash[:error] = group.cannot_destroy_reason
        break
      end
    end
  end

  def check_extensions
    @agent.extensions.each do |extension|
      if Node.has_extension?(extension)
        flash[:error] = t('extension_config.used_by_exchange')
        break
      end
    end
  end

  def disable_agent
    unless RedisHelp.agent_can_be_destroy?(@agent)
      flash[:error] = "本次操作被系统拒绝处理，原因是“您正在禁用的座席#{@agent.id}的状态不符合可以被禁用的条件。”只有当座席状态是“就绪+空闲”或“登出+空闲”时才可以禁用。您可以等一会后再来操作。"
    end
    check_agent_groups_members unless flash[:error]
    check_agent_state_in_groups unless flash[:error]
    check_extensions unless flash[:error]

    unless flash[:error]
      RecoverAgent.create(company_id: @agent.company_id,
                          agent_id: @agent.id,
                          group_id: @agent.outbound_group_id,
                          salesman_id: @agent.salesman_id,
                          show_number: @agent.show_number,
                          group_user_ids: @agent.outbound_group.present? ? @agent.outbound_group.users.pluck(:id).join(',') : nil)
      @agent.groups.each { |group| group.destroy if group.agents.count <= 1 }
      @agent.disable
      flash[:notice] = t('agent.deleted', w: @agent.code)
    end
  end
end
