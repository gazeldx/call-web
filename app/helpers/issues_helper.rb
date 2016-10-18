module IssuesHelper
  def issue_state(state)
    css = ['inverse', 'primary', 'danger', 'success', 'default'].map do |color|
      "label label-#{color}"
    end

    raw(content_tag(:span, t("issue.state_#{state}"), class: css[state]))
  end

  def options_for_issue_handler
    options_for_select((current_company.users + current_company.salesmen).map { |person| ["#{person.name}（#{person.is_a?(User) ? t(:user_) : t(:salesman_)}）", "#{person.is_a?(User) ? 'u' : 's'}#{person.id}"] }.unshift([t('issue.please_select_handler'), nil]), "#{@issue.handler_type == Issue::HANDLER_TYPE_SALESMAN ? 's' : 'u'}#{@issue.handler_id}")
  end

  def options_for_issue_handler_search
    options_for_select((current_company.users + current_company.salesmen).map { |person| ["#{person.name}（#{person.is_a?(User) ? t(:user_) : t(:salesman_)}）", person.id] }.unshift([t('issue.handler'), nil]), params[:handler_id])
  end

  def options_for_issue_creator_search
    options_for_select((current_company.users + current_company.salesmen).map { |person| ["#{person.name}（#{person.is_a?(User) ? t(:user_) : t(:salesman_)}）", person.id] }.unshift([t('issue.creator'), nil]), params[:creator_id])
  end
end
