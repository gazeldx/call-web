class ReportAgentDailiesController < BaseController
  include Search, SearchTeam

  helper_method :united_agent_id

  def index
    @report_agent_dailies = current_user.report_agent_dailies
    @report_agent_dailies = equal_search(@report_agent_dailies, [:salesman_id, :agent_id, :call_type])
    @report_agent_dailies = search_team(@report_agent_dailies)

    if params[:target_date].present?
      target_date = DateTime.parse(params[:target_date])
      @report_agent_dailies = @report_agent_dailies.where(target_date: target_date.beginning_of_day..target_date.end_of_day)
      @sum = @report_agent_dailies.select(sum_as_columns).to_a[0] unless united_agent_id
    end

    if united_agent_id
      @report_agent_dailies = @report_agent_dailies.select("target_date, salesman_id, #{sum_as_columns}").group('target_date, salesman_id')
      @report_count = @report_agent_dailies.to_a.size
      @report_agent_dailies = @report_agent_dailies.includes([salesman: :team]).order(target_date: :desc)
    else
      @report_agent_dailies = @report_agent_dailies.includes([salesman: :team], :agent).order(target_date: :desc)
      order_by
    end

    if params[:target_method] == 'export'
      export_dailies
    else
      if united_agent_id
        @report_agent_dailies = @report_agent_dailies.paginate(page: params[:page], total_entries: @report_count) # Notice: 因为will_paginate对group+order的total_entries默认统计值不准确, 所以手工统计下total_entries
      else
        @report_agent_dailies = @report_agent_dailies.page(params[:page])
      end
    end
  end

  def monthlies
    # TODO: 月报表没有显示团队
    @report_agent_monthlies = current_user.report_agent_dailies.select("agent_id, salesman_id, date_trunc('month', target_date) as target_month, #{sum_as_columns}").where("date_trunc('month', target_date) = ?", "#{Date.valid_month?(params[:month]) ? params[:month] : Time.now.strftime("%Y%m")}01").group('target_month, agent_id, salesman_id').includes(:salesman, :agent).sort_by { |report| [report.target_month, report.talk_count] }.reverse
  end

  def days
    if params[:start_date].present?
      @report_agent_days = current_user.report_agent_dailies
      @report_agent_days = equal_search(@report_agent_days, [:salesman_id, :agent_id])
      @report_agent_days = search_team(@report_agent_days)
      @report_agent_days = @report_agent_days.where(target_date: DateTime.parse(params[:start_date]).beginning_of_day..DateTime.parse(params[:end_date]).end_of_day)
      @sum = @report_agent_days.select(sum_as_columns).to_a[0]
      @report_agent_days = @report_agent_days.select("agent_id, salesman_id, #{sum_as_columns}").group('agent_id, salesman_id').includes([salesman: :team], :agent).sort_by { |report| [report.talk_count] }.reverse
      export_days if params[:target_method] == 'export'
    end
  end

  def today
    @salesmen = current_user.salesmen.select(:id, :name)

    @cached_reports = RedisHelp.agents_today_report(current_user.company_id) # @cached_reports内容举例: {"created_at"=>"1456737959", "query_at"=>"1456737999", "reports"=>"[{\"agentId\":100151003,\"answerCount\":0,\"averageDuration\":0,\"checkinCount\":0,\"checkinDuration\":0,\"companyId\":10015,\"cost\":0.0,\"salesmanId\":5193,\"talkCount\":0,\"talkDuration\":0,\"talkMinutes\":0,\"targetDate\":1456737752126,\"triggerCount\":5},{\"agentId\":100151005,\"answerCount\":0,\"averageDuration\":0,\"checkinCount\":0,\"checkinDuration\":0,\"companyId\":10015,\"cost\":0.0,\"salesmanId\":3,\"talkCount\":0,\"talkDuration\":0,\"talkMinutes\":0,\"targetDate\":1456737752149,\"triggerCount\":0},{\"agentId\":100151005,\"answerCount\":0,\"averageDuration\":0,\"checkinCount\":0,\"checkinDuration\":0,\"companyId\":10015,\"cost\":0.0,\"salesmanId\":0,\"talkCount\":0,\"talkDuration\":0,\"talkMinutes\":0,\"targetDate\":1456737752160,\"triggerCount\":0},{\"agentId\":100151007,\"answerCount\":0,\"averageDuration\":0,\"checkinCount\":0,\"checkinDuration\":0,\"companyId\":10015,\"cost\":0.0,\"salesmanId\":6,\"talkCount\":0,\"talkDuration\":0,\"talkMinutes\":0,\"targetDate\":1456737752201,\"triggerCount\":0},{\"agentId\":100151006,\"answerCount\":0,\"averageDuration\":0,\"checkinCount\":0,\"checkinDuration\":0,\"companyId\":10015,\"cost\":0.0,\"salesmanId\":0,\"talkCount\":0,\"talkDuration\":0,\"talkMinutes\":0,\"targetDate\":1456737752409,\"triggerCount\":0},{\"agentId\":100151006,\"answerCount\":0,\"averageDuration\":0,\"checkinCount\":0,\"checkinDuration\":0,\"companyId\":10015,\"cost\":0.0,\"salesmanId\":9,\"talkCount\":0,\"talkDuration\":0,\"talkMinutes\":0,\"targetDate\":1456737752460,\"triggerCount\":0}]"}
    if @cached_reports.present? && (Time.now.to_i - @cached_reports['created_at'].to_i > ReportAgentDaily::CACHED_MINUTES * 60)
      if @cached_reports['query_at'].blank? || (Time.now.to_i - Integer(@cached_reports['query_at']) > 60) # 距离上次查询已经过了1分钟, 就可以再次查询了, 防止重复查询而导致数据库负荷过大
        @cached_reports = nil # 设置为nil后, 页面会通过Ajax调用到下面的 publish_message method. 否则在页面直接显示@cached_reports内容
      end
    end

    RedisHelp.update_query_at_of_agents_today_report(current_user.company_id)
  end

  def publish_message
    begin
      ::Publisher.directPublish('ReportRequestExchange', 'ReportRequest', { messageId: 2002, companyId: current_company.id })

      render json: { result: '统计中，请稍等......' }
    rescue Exception => e
      logger.error "向报表服务器发送统计消息失败 ::Publisher.directPublish('ReportRequestExchange', 'ReportRequest', { messageId: 2002, companyId: current_company.id }) has exception: #{e.message}"
      render json: { result: "向报表服务器发送统计消息失败。具体原因是：#{e.message} #{e.class}" }
    end
  end

  def dailies_sum
    @dailies = current_user.report_agent_dailies.select("target_date, #{sum_as_columns}").group('target_date').order(target_date: :desc).page(params[:page])
  end

  def united_agent_id
    params[:united] == 'agent_id'
  end

  def order_by
    @report_agent_dailies = @report_agent_dailies.order(order_field)
  end

  private

  def export_dailies
    logger.warn("====== #{Time.now.strftime(t("time_without_year"))} start export ============")
    content = dailies_csv_content.encode('gbk', 'utf-8')
    logger.warn("====== #{Time.now.strftime(t("time_without_year"))} end   export ============")
    send_data(content, filename: "agents_dailies.csv") # TODO: filename如果搜索加日期了, 就把日期放在文件名里面
  end

  def dailies_csv_content
    csv_array = []
    if @sum.present? && @sum.trigger_count.present?
      sum = ['汇总', '', '']
      sum += ['', ''] unless united_agent_id
      sum += [@sum.trigger_count, @sum.answer_count, "#{@sum.trigger_count > 0 ? ((@sum.answer_count.to_f / @sum.trigger_count) * 100).round(1) : 0}%", DateTime.seconds_to_words_global(@sum.talk_duration)]
      sum << DateTime.seconds_to_words_global(@sum.talk_count.to_i == 0 ? 0 : @sum.talk_duration.to_i / @sum.talk_count) unless united_agent_id
      sum += [@sum.talk_minutes, @sum.cost.to_f.round(2), '']
      sum << '' unless united_agent_id
      sum << ''
      csv_array << sum.join(',')
    end
    # TODO: 团队未加入到csv中
    titles = [t('report_agent_daily.target_date'), t(:week_day), t(:salesman_)]
    titles += [t(:agent_), t('report_agent_daily.call_type')] unless united_agent_id
    titles += [t('report_agent_daily.trigger_count'), t('report_agent_daily.talk_count'), t('report_agent_daily.bridged_ratio'), t('report_agent_daily.talk_duration')]
    titles << "#{t('report_agent_daily.average_duration')}（#{t(:second)}）" unless united_agent_id
    titles += [t('report_agent_daily.talk_minutes_'), "#{t('report_agent_daily.cost')}（#{t(:yuan)}）", t('report_agent_daily.checkin_duration')]
    titles << "#{t('report_agent_daily.average_checkin_duration')}" unless united_agent_id
    titles << t('report_agent_daily.checkin_count')
    csv_array << titles.join(',')
    # TODO: 这里导出1万条就超时了。
    @report_agent_dailies.each { |daily| csv_array << daily_line(daily) }
    csv_array.join("\n")
  end

  def daily_line(daily)
    line = [
      daily.target_date.strftime(t(:date_format_)),
      daily.target_date.wday_name,
      daily.salesman.try(:name)
    ]
    line += [daily.agent.try(:code), t("report_agent_daily.call_type_#{daily.call_type}")] unless united_agent_id
    line += [
      daily.trigger_count,
      daily.talk_count.to_i,
      ratio(daily.talk_count, daily.trigger_count),
      DateTime.seconds_to_words_global(daily.talk_duration)
    ]
    line << daily.average_duration unless united_agent_id
    line += [
      daily.talk_minutes,
      daily.cost,
      DateTime.seconds_to_words_global(daily.checkin_duration)
    ]
    line << DateTime.seconds_to_words_global(daily.checkin_count.to_i == 0 ? 0 : daily.checkin_duration.to_i / daily.checkin_count) unless united_agent_id
    line << daily.checkin_count
    line.join(',')
  end

  def export_days
    logger.warn("====== #{Time.now.strftime(t("time_without_year"))} start days export ============")
    content = days_csv_content.encode('gbk', 'utf-8')
    logger.warn("====== #{Time.now.strftime(t("time_without_year"))} end days export ============")
    send_data(content, filename: "days.csv") # TODO: filename如果搜索加日期了, 就把日期放在文件名里面
  end

  def days_csv_content
    csv_array = []
    if @sum.present? && @sum.trigger_count.present?
      sum = ['汇总', '']
      sum += [@sum.trigger_count, @sum.answer_count, "#{@sum.trigger_count > 0 ? ((@sum.answer_count.to_f / @sum.trigger_count) * 100).round(1) : 0}%", DateTime.seconds_to_words_global(@sum.talk_duration)]
      sum += [@sum.talk_minutes, @sum.cost.to_f.round(2)]
      csv_array << sum.join(',')
    end
    # TODO: 团队未加入到csv中
    titles = [t(:salesman_), t(:agent_), t('report_agent_daily.trigger_count'), t('report_agent_daily.talk_count'), t('report_agent_daily.bridged_ratio'), t('report_agent_daily.talk_duration'), t('report_agent_daily.talk_minutes_'), "#{t('report_agent_daily.cost')}（#{t(:yuan)}）"]
    csv_array << titles.join(',')
    @report_agent_days.each { |daily| csv_array << day_line(daily) }
    csv_array.join("\n")
  end

  def day_line(day)
    line = [
      day.salesman.try(:name),
      day.agent.try(:code),
      day.trigger_count,
      day.talk_count.to_i,
      ratio(day.talk_count, day.trigger_count),
      DateTime.seconds_to_words_global(day.talk_duration),
      day.talk_minutes,
      day.cost
    ]
    line.join(',')
  end

  def sum_as_columns
    "sum(trigger_count) as trigger_count, sum(answer_count) as answer_count, sum(talk_count) as talk_count, sum(talk_duration) as talk_duration, sum(talk_minutes) as talk_minutes, sum(cost) as cost, sum(checkin_duration) as checkin_duration, sum(checkin_count) as checkin_count"
  end

  def order_field
    if params[:orderBy].present?
      if params[:orderBy].end_with?('_desc')
        return { params[:orderBy].slice(0, params[:orderBy].size - '_desc'.size) => :desc }
      else
        return { params[:orderBy].slice(0, params[:orderBy].size - '_asc'.size) => :asc }
      end
    else
      params[:orderBy] = 'talk_count_desc'
      return { talk_count: :desc }
    end
  end
end
