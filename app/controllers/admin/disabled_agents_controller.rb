class Admin::DisabledAgentsController < Admin::BaseController
  include Search

  def index
    @disabled_agents = DisabledAgent.all
    @disabled_agents = equal_search(@disabled_agents, [:company_id])
    @disabled_agents = @disabled_agents.includes(:agent, :company).paginate(page: params[:page], per_page: 100).order('id DESC')
  end

  def destroy
    @disabled_agent = DisabledAgent.find(params[:id])

    @disabled_agent.destroy

    redirect_to request.referer, notice: t('disabled_agent.deleted', w: @disabled_agent.agent_id)
  end
end
