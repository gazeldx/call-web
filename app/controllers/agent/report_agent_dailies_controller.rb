class Agent::ReportAgentDailiesController < SalesmanBaseController
  include Search

  def index
    @report_agent_dailies = current_user.report_agent_dailies.includes(:agent).order('target_date DESC').page(params[:page])
  end

  def monthlies
    @report_agent_monthlies = current_user.report_agent_dailies.select("agent_id, salesman_id, date_trunc('month', target_date) as month, sum(trigger_count) as trigger_count, sum(answer_count) as answer_count, sum(talk_count) as talk_count, sum(talk_duration) as talk_duration, sum(talk_minutes) as talk_minutes, sum(cost) as cost, sum(checkin_duration) as checkin_duration, sum(checkin_count) as checkin_count").group('month, agent_id, salesman_id').includes([agent: :extensions]).sort_by { |report| [report.month, report.trigger_count] }.reverse
  end

  def days
    if params[:start_date].present?
      @report_agent_days = current_user.report_agent_dailies
      @report_agent_days = equal_search(@report_agent_days, [:agent_id])
      @report_agent_days = @report_agent_days.where(target_date: DateTime.parse(params[:start_date]).beginning_of_day..DateTime.parse(params[:end_date]).end_of_day).select("agent_id, salesman_id, sum(trigger_count) as trigger_count, sum(answer_count) as answer_count, sum(talk_count) as talk_count, sum(talk_duration) as talk_duration, sum(talk_minutes) as talk_minutes, sum(cost) as cost, sum(checkin_duration) as checkin_duration, sum(checkin_count) as checkin_count").group('agent_id, salesman_id').includes([agent: :extensions]).sort_by { |report| [report.trigger_count] }.reverse
    end
  end
end
