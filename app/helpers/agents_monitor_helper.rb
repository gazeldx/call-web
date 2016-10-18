module AgentsMonitorHelper
  def agent_color_prior(redis_agent, status, state, sign)
    prior = redis_agent.second

    if redis_agent.first == 'Not_Ready' && redis_agent.second == 'Waiting'
      prior = redis_agent.first
    end

    if redis_agent.third == '1' && redis_agent.second == 'Waiting'
      prior = redis_agent.third
    end

    if prior == redis_agent.first
      status[prior][:color]
    elsif prior == redis_agent.third
      sign[prior][:color]
    else
      state[prior][:color]
    end
  end
end
