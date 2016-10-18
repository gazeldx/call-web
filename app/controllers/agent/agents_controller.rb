class Agent::AgentsController < SalesmanBaseController
  def update_show_number
    if current_company.phone_numbers.agent_numbers.pluck(:number).include?(params[:show_number])
      RedisHelp.update_agent_show_number(current_user.agent.id, current_user.agent.show_number) if current_user.agent.update(show_number: params[:show_number])
      render json: { show_number: current_user.agent.show_number }
    end
  end
end
