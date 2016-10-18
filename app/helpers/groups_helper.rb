module GroupsHelper
  def inbound_or_outbound(outbound)
    if outbound
      content_tag(:span, t('group.outbound'), class: 'label label-sm label-info')
    else
      content_tag(:span, t('group.inbound'), class: 'label label-sm label-danger')
    end
  end

  def groups_checkbox(form)
    content_tag(:div,
                labeled(:groups) + content_tag(:div,
                                               form.collection_check_boxes(:group_ids, current_company.groups.state_ok.order('created_at'), :id, :checkbox_name),
                                               class: 'col-sm-9'),
                class: 'form-group') if policy(:group2).modify_groups?
  end

  def agents_checkbox_for_group(agents)
    result = ''

    agents.each do |agent|
      result = result +
      "<input id='group_agent_ids_#{agent.id}' name='group[agent_ids][]' type='checkbox' value='#{agent.id}' #{group_agent_checked_or_not(agent.id)} />" +
      "<label for='group_agent_ids_#{agent.id}' title='#{extension_tooltip(agent)}' data-rel='tooltip' data-html='true'>&nbsp;#{agent.code}&nbsp;&nbsp;&nbsp;&nbsp;</label>"
    end

    raw(result)
  end

  private

  def group_agent_checked_or_not(agent_id)
    @group.agents.map(&:id).include?(agent_id) ? 'checked' : ''
  end
end
