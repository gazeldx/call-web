class AgentsController < BaseController
  include Search

  before_action :set_agent, only: [:edit, :update, :disable_eom]

  def index
    @agents = current_user.agents
    @agents = equal_search(@agents, [:salesman_id, :code])
    @agents = like_search(@agents, [:show_number])
    @agents = @agents.where(id: Ag.where(group_id: params[:group_id]).pluck(:agent_id)) if params[:group_id].present?

    # TODO: 日志显示有几个表没有eager loading, 可以考虑优化下
    @agents = @agents.includes(:salesman, :groups, :extensions, :charge_changes).page(params[:page]).order('id DESC')
  end

  def edit
    set_return_to
  end

  def update
    authorize current_company.agents.build(agent_params.merge(id: @agent.id))

    if @agent.update(agent_params)
      RedisHelp.update_agent_show_number(@agent.id, @agent.show_number)
      RedisHelp.set_agent_salesman_id(@agent.id, @agent.salesman_id)

      flash[:notice] = t('agent.updated')
      return_to
    else
      render :edit
    end
  end

  def batch_config
  end

  def do_batch_config
    params[:agent_ids].each do |agent_id|
      agent = Agent.find(agent_id)
      agent.show_number = params[:show_number]

      authorize(agent, :update?)

      RedisHelp.update_agent_show_number(agent.id, agent.show_number) if agent.save
    end

    redirect_to agents_path, notice: t('agent.batch_configured')
  end

  def disable_eom
    authorize @agent

    DisabledAgent.create!(company_id: @agent.company_id, agent_id: @agent.id)

    redirect_to request.referer, notice: t('agent.disabled_eom_user', w: @agent.code)
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:salesman_id, :extension, :show_number)
  end
end
