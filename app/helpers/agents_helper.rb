module AgentsHelper
  def agent_shown(agent)
    if agent.present?
      content_tag(:span, agent.code, title: extension_tooltip(agent), 'data-rel' => 'tooltip', 'data-html' => 'true')
    end
  end

  def extension_tooltip(agent)
    # TODO: 已绑定的呼出组显示用效率更高的方式实现下
    # 这里可能是rails的bug, 因为salesman.name没有通过eager_loading加载, 所以用这种方式(座席组数量过多时, 不显示销售员姓名)来达到效率的提升
    salesman_name = (@group.present? || (@groups.present? && @groups.count < 5)) ? agent.salesman.try(:name) : agent.salesman_id
    "#{t(:salesman_)}：#{salesman_name || t(:none)}<br>#{t('agent.show_number')}：#{agent.show_number}<br>#{t('agent.code')}：#{agent.code}"
  end

  def agent_state(agent)
    css = ['danger', 'success', 'warning'].map do |color|
      "label label-sm label-#{color}"
    end

    raw(content_tag(:span, t("agent.state_#{agent.state}"), class: css[agent.state]))
  end

  def agent_out(agent_id)
    color = { 'Available' => 'success', 'NotAvailable' => 'danger', '' => 'mute' }
    raw(content_tag(:span, t("agent.out_#{RedisHelp.get_agent_out(agent_id).to_s}"), class: "label label-sm label-#{color[RedisHelp.get_agent_out(agent_id).to_s]}"))
  end

  def agents_checkboxes(agents)
    result = ''

    agents.each do |agent|
      result = result +
          "<input id='agent_ids_#{agent.id}' name='agent_ids[]' type='checkbox' value='#{agent.id}' />" +
          "<label for='agent_ids_#{agent.id}' title='#{extension_tooltip(agent)}' data-rel='tooltip' data-html='true'>&nbsp;#{agent.code}&nbsp;&nbsp;&nbsp;&nbsp;</label>"
    end

    raw(result)
  end

  def display_show_number(form = nil)
    numbers = current_company.phone_numbers.agent_numbers.map { |number| [number.number, number.number] }.unshift(['无', nil])
    if form.nil?
      select_options =  select_tag(:show_number, options_for_select(numbers), {class: 'required'})
    else
      select_options = form.select(:show_number, options_for_select(numbers, @agent.show_number), {}, {class: 'required'})
    end

    raw(content_tag(:div, labeled(:show_number, required: true) + content_tag(:div, select_options, class: 'col-sm-9'), class: 'form-group'))
  end

  def agent_charge_change_info(agent)
    html = ''
    if agent.charge_changes.not_processed.present?
      charge_id = agent.charge_changes.not_processed.first.charge_id
      html += "<br>"
      html += content_tag(:span,
                          "下月变更为：#{"#{charge_id} - #{ChargeAgent.get_class_name_by_charge_id(charge_id).find(charge_id).try(:name)}"}",
                          class: 'text-primary')
    end
    raw(html)
  end

  # private

  # def extensions_title(agent)
  #   (agent.extension_names == t(:no_extension) ? '<br>分机：无，请先设置本座席分机号' : '')
  # end
end
