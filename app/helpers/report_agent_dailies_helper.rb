module ReportAgentDailiesHelper
  def report_call_type(call_type)
    call_type = call_type.to_i
    css = ['default', 'danger'].map { |color| "label label-sm label-#{color}" }
    raw(content_tag(:span, t("report_agent_daily.call_type_#{call_type}"), class: css[call_type]))
  end

  def report_agent_dailies_header_links
    raw " #{link_to raw("#{t('report_agent_daily.today_header')}#{report_agent_dailies_selected_header(report_agent_today_path)}"), report_agent_today_path, class: 'btn btn-sm btn-success'}
      #{link_to raw("#{t('report_agent_daily.daily_header')}#{report_agent_dailies_selected_header(report_agent_dailies_path)}"), report_agent_dailies_path, class: 'btn btn-sm btn-primary'}
      #{link_to raw("#{t('report_agent_daily.days_header')}#{report_agent_dailies_selected_header(report_agent_days_path)}"), report_agent_days_path, class: 'btn btn-sm btn-warning'}
      #{link_to raw("#{t('report_agent_daily.monthly_header')}#{report_agent_dailies_selected_header(report_agent_monthlies_path)}"), report_agent_monthlies_path, class: 'btn btn-sm btn-danger'}
    "
  end

  def salesman_report_agent_dailies_header_links
    raw " #{link_to t('report_agent_daily.today_header'), '#modal-table', class: 'btn btn-sm btn-success', role: 'button', 'data-toggle' => 'modal', onclick: 'javascript: querySalesmanToday();'}
      #{link_to raw("#{t('report_agent_daily.daily_header')}#{report_agent_dailies_selected_header(report_agent_daily_path)}"), report_agent_daily_path, class: 'btn btn-sm btn-primary'}
      #{link_to raw("#{t('report_agent_daily.days_header')}#{report_agent_dailies_selected_header(report_agent_day_path)}"), report_agent_day_path, class: 'btn btn-sm btn-warning'}
      #{link_to raw("#{t('report_agent_daily.monthly_header')}#{report_agent_dailies_selected_header(report_agent_monthly_path)}"), report_agent_monthly_path, class: 'btn btn-sm btn-danger'}
      #{render 'today'}
      "
  end

  def checkin_duration_average(checkin_duration, checkin_count)
    "#{DateTime.seconds_to_words_global(checkin_duration)} / #{DateTime.seconds_to_words_global(checkin_count.to_i == 0 ? 0 : checkin_duration.to_i / checkin_count)}"
  end

  private

  def report_agent_dailies_selected_header(path)
    if request.path == path
      " #{icon(:bug)}"
    end
  end
end
