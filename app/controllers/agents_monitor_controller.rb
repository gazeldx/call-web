class AgentsMonitorController < BaseController
  # layout 'bone'

  def index
    @agents = current_user.agents.includes(:salesman, :groups, :extensions).order(:id)
  end

  # 监控单个座席, 目前仅支持通过API接口呼叫的座席状态
  def single_agent
    @agent = Agent.find("#{current_company.id}#{params[:agent_code]}")
  end
end
