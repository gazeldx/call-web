module SearchHelper
  def salesman_container
    salesmen_options = current_user.salesmen.order(:name).map { |salesman| [salesman.name, salesman.id] }
    salesmen_options.unshift([t(:salesman_id_is_null), 'null']) if current_user.admin?
    content_tag(:span,
                select_tag(:salesman_id, options_for_select(salesmen_options.unshift([t(:salesman_), nil]), params[:salesman_id])),
                id: 'salesman_id_container',
                class: hide_or_show_css(:salesman_id))
  end

  def agent_container
    agents_options = current_company.agents.order(:id).map { |agent| [agent.code, agent.id] }
    agents_options.unshift([t('cdr.agent_id_is_null'), 'null']) if current_user.is_a?(User) && current_user.admin? # 销售员是不需要加入本选项的,因为销售员目前在座席上打电话
    content_tag(:span,
                select_tag(:agent_id, options_for_select(agents_options.unshift([t(:agent_), nil]), params[:agent_id])),
                id: 'agent_id_container',
                class: hide_or_show_css(:agent_id))
  end

  def team_container
    if current_user.manage_many_teams?
      team_options = current_user.teams_.order(:name).map { |team| [team.name, team.id] }
      team_options.unshift([t(:team_id_is_null), 'null']) if current_user.admin?
      content_tag(:span,
                  select_tag(:team_id, options_for_select(team_options.unshift([t(:team_), nil]), params[:team_id])),
                  id: 'team_id_container',
                  class: hide_or_show_css(:team_id))
    end
  end

  def company_container
    content_tag(:span,
                text_field_tag(:company_id, params[:company_id], placeholder: t('company.id'), style: 'vertical-align: middle; width: 70px'),
                id: 'company_id_container',
                class: hide_or_show_css(:company_id))
  end

  def task_container
    tasks_options = current_user.tasks.where(state: [Task::STATE_RUNNING, Task::STATE_PAUSED, Task::STATE_FINISHED, Task::STATE_STASHED]).where('started_at > ?', DateTime.now - ("/#{controller_path}" == invalid_cdrs_path ? 6 : 91).days).order(started_at: :desc).map { |task| ["#{task.started_at.strftime(t(:date_without_year))}_#{task.name}", task.id] }
    content_tag(:span,
                select_tag(:task_id, options_for_select(tasks_options.unshift([t('task.short_name'), nil]), params[:task_id])),
                id: 'task_id_container',
                class: hide_or_show_css(:task_id))
  end

  def group_container
    groups_options = current_user.groups_.state_ok.order(:id).map { |group| [group.name, group.id] }
    content_tag(:span,
                select_tag(:group_id, options_for_select(groups_options.unshift([t(:group_), nil]), params[:group_id])),
                id: 'group_id_container',
                class: hide_or_show_css(:group_id))
  end
end
