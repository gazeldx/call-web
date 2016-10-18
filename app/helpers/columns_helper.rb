module ColumnsHelper
  TARGET_CSS = ['', 'pink2', 'green']

  def column_type(column)
    if column.name.start_with?('s')
      content_tag(:span, t('column.string'), class: 'text-default')
    elsif column.select?
      content_tag(:span, t('column.enum'), class: 'text-danger')
    elsif column.name.start_with?('dt')
      content_tag(:span, t('column.datetime'), class: 'text-primary')
    elsif column.name.start_with?('d')
      content_tag(:span, t('column.date'), class: 'text-success')
    end
  end

  def column_target_name(column)
    content_tag(:span, t("column.target_#{column.target}"), class: TARGET_CSS[column.target])
  end

  def column_options_html(column)
    html = "<option value=''>#{column.title}</option>"

    html += column.options.order(:created_at).map do |option|
      "<option value='#{option.value}' #{params[column.name.to_sym].to_i == option.value ? 'selected' : nil }>#{option.text}</option>"
    end.join('')
    html += "<option value='null' #{params[column.name.to_sym] == 'null' ? 'selected' : nil }>#{t(:no_data)}</option>"

    html
  end

  def column_date_search(column)
    date_start = "#{column.name}_start"
    date_end = "#{column.name}_end"
    html = " #{column.title}：从"
    html += content_tag(:div, text_field_tag(date_start, (params[date_start] ? params[date_start] : nil), class: 'date-picker'), class: 'inline')
    html += '至 '
    html += content_tag(:div, text_field_tag(date_end, (params[date_end] ? params[date_end] : Time.now.strftime(t(:date_format_))), class: 'date-picker'), class: 'inline')
    "#{html} "
  end

  def column_checkbox_for_search(column)
    if column.date?
      checkbox_for_search_with_value("#{column.name}_start".to_sym, Time.now.strftime(t(:date_format_)))
    else
      checkbox_for_search(column.name.to_sym)
    end
  end

  def column_active(column)
    if column.active?
      content_tag(:span, t('column.active_true'), class: 'label label-sm label-info')
    else
      content_tag(:span, t('column.active_false'), class: 'label label-sm label-default')
    end
  end
end
