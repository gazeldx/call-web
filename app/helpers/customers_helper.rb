module CustomersHelper
  def customer_form_groups(form)
    @width_sum = 0
    form_group = "<div class='form-group' style='text-align: right'>"

    sorted_columns.each do |column|
      form_group += automatic_form_group(column, form)
    end

    raw "#{form_group} #{salesmen_select(form) if user?} #{form.hidden_field(:act)} #{hidden_field_tag(:act, params[:act])}</div>"
  end

  def customer_submits
    submit = content_tag(:button, raw("#{content_tag(:i, nil, class: 'icon-ok bigger-110')} #{t(:submit)}"), type: 'submit', class: 'btn btn-info') + raw('&nbsp; &nbsp; &nbsp; &nbsp;')

    if !new_or_create?
      if @customer.act_as_customer?
        generate_button = content_tag(:button, raw("#{content_tag(:i, nil, class: 'icon-unlink bigger-110')} #{t('clue.generate')}"), type: 'submit', class: 'btn btn-warning', title: '点击后，会保存当前修改并将本信息转为“销售线索”；“客户名单”页面将不再显示。', 'data-rel' => 'tooltip', onclick: "$('#customer_act').val(#{Customer::ACT_CLUE});") + raw('&nbsp; &nbsp; &nbsp; &nbsp;')
      elsif @customer.act_as_clue?
        generate_button = content_tag(:button, raw("#{content_tag(:i, nil, class: 'icon-male bigger-110')} #{t('customer.create')}"), type: 'submit', class: 'btn btn-warning', title: '点击后，会保存当前修改并将本信息转为“客户名单”；“销售线索”页面将不再显示。', 'data-rel' => 'tooltip', onclick: "$('#customer_act').val(#{Customer::ACT_CUSTOMER});") + raw('&nbsp; &nbsp; &nbsp; &nbsp;')
      else
        ''
      end
    end

    content_tag(:div, content_tag(:div, submit + generate_button, class: 'col-md-offset-3 col-md-9'), class: 'clearfix form-actions')
  end

  def customer_contacts_tip(customer)
    contacts = "<b class='green'>#{t('contact.history')}</b><br>"

    customer.contacts.each do |contact|
      contacts = "#{contacts}#{contact.operator_name}: #{contact.remark} (#{time_ago_in_words(contact.created_at)})<br>"
    end

    customer.contacts.blank? ? nil : contacts
  end

  def customers_add_only_checkbox
    content_tag(:span, raw("#{check_box_tag(:add_only, true, true)}只新增新客户，不更新已有客户信息（不勾选表示不仅会新增新客户，还会更新已有客户。一般保持默认的勾选就对了）"),
                  class: 'green',
                  title: '勾选后，系统只会新增不存在的号码，不会修改已经存在于销售线索和客户名单中的信息（已经删除的和弹屏用的隐藏的信息仍会被更新）',
                  'data-rel' => 'tooltip')
  end

  def package_customers_records
    if policy(:record_package2).download?
      result = raw("&nbsp;")
      if @customers.count > Customer::MAX_PACKAGE_RECORDS_CUSTOMERS_COUNT
        result << content_tag(:button, t('record.package'), type: 'button', class: 'hidden_when_submit btn btn-default btn-sm', 'data-title' => "一次打包的录音数量过多！请控制客户数量在#{Customer::MAX_PACKAGE_RECORDS_CUSTOMERS_COUNT}以内。", 'data-rel' => 'tooltip')
      else
        result << package_records_button
      end
    end
  end

  def export_customer_button
    result = raw("&nbsp;")
    if SystemConfig.free_time? || @customers.count <= Customer::MAX_EXPORT_COUNT_ON_BUSY_TIME
      result << export_button
    else
      result << content_tag(:button, t(:export_result), type: 'button', class: 'hidden_when_submit btn btn-default btn-sm', id: 'export_button', 'data-content' => "客户数量在#{Customer::MAX_EXPORT_COUNT_ON_BUSY_TIME}条以内可以直接导出。本次要导出的客户数超过了#{Customer::MAX_EXPORT_COUNT_ON_BUSY_TIME}条，请分多次导出，每次控制客户数在#{Customer::MAX_EXPORT_COUNT_ON_BUSY_TIME}条以内；或者如果您想一次导完，#{t(:operate_at_free_time)}", 'data-rel' => 'popover', 'data-trigger' => 'hover', 'data-placement' => 'top', 'data-html' => 'true', onclick: "alert('#{t(:operate_at_free_time)}')")
    end
    result
  end

  def import_csv_tool_description
    tool_link = content_tag(:a, '下载专业级csv文件编辑器', href: "#{ucweb_url}/sharedfs/files/Notepad69.exe")
    content_tag(:span, tool_link,
                class: 'green',
                'data-content' => '微软Excel无法完成“替换英文双引号”操作，定位到行号操作也不方便。<br>建议用专业级的文件编辑工具Notepad。请点此下载安装。<br>Notepad使用说明：1、“<span class="red">Ctrl + H</span>”是替换； 2、“<span class="red">Ctrl + G</span>”跳转到指定行', 'data-rel' => 'popover', 'data-html' => 'true', 'data-trigger' => 'hover', 'data-placement' => 'top')
  end

  private

  def automatic_form_group(column, form)
    content = "#{content_tag(:label, (['s1', 's2'].include?(column.name) ? content_tag(:span, '*', class: 'text-danger') : '') + column.title, class: "col-xs-1 #{ColumnsHelper::TARGET_CSS[column.target]}")}#{column_input(column, form)}"

    @width_sum += column.width

    if @width_sum > Column::MAX_WIDTH
      @width_sum = column.width

      return "</div><div class='form-group' style='text-align: right'>#{content}"
    else
      return content
    end
  end

  def column_input(column, form)
    if column.select?
      options = column.options.order(:created_at).map { |option| [option.text, option.value] }.unshift([t(:unselected), nil])
      form.select(column.name.to_sym, options_for_select(options, @customer.try(column.name)), {}, { class: column_input_css(column) })
    elsif column.text?
      if column.name == 's1' && !policy(:company_config2).salesman_can_see_numbers? && current_user.is_a?(Salesman) && !new_or_create? # 针对需要对销售员隐藏客户号码的情况
        content_tag(:span, hide_middle_digits(@customer.s1), class: column_input_css(column))
      else
        form.text_field(column.name.to_sym, class: column_input_css(column))
      end
    elsif column.date?
      form.text_field(column.name.to_sym, class: "date-picker #{column_input_css(column)}")
    end
  end

  def column_input_css(column)
    "col-xs-#{column.width * 3 - 1}"
  end

  def sorted_columns
    result = []

    if @customer.act_as_both?
      columns = company_columns.to_a
    elsif @customer.act_as_customer?
      columns = customer_columns.to_a
    elsif @customer.act_as_clue?
      columns = clue_columns.to_a
    end

    width_sum = 0

    columns.clone.each do |column|
      unless result.include?(column)
        if width_sum + column.width < Column::MAX_WIDTH
          result << column; columns.delete(column)
          width_sum += column.width
        elsif width_sum + column.width == Column::MAX_WIDTH
          result << column; columns.delete(column)
          width_sum = 0
        else
          columns.delete(column)

          columns.clone.each do |clm|
            if width_sum + clm.width < Column::MAX_WIDTH
              result << clm; columns.delete(clm)
              width_sum += clm.width
            elsif width_sum + clm.width == Column::MAX_WIDTH
              result << clm; columns.delete(clm)
              break
            end
            width_sum = 0 if clm == columns.last
          end

          result << column
          width_sum = column.width % Column::MAX_WIDTH
        end
      end
    end until columns.size <= 1

    result.concat(columns)
  end

  def salesmen_select(form)
    label = content_tag(:label, t(:salesman_), class: 'col-xs-1')

    salesmen = current_user.salesmen.order(:name).map { |salesman| [salesman.name, salesman.id] }.unshift([t(:unselected), nil])

    select = form.select(:salesman_id, options_for_select(salesmen, @customer.salesman_id), {}, { class: 'col-xs-2 select2' })

    result = label + select

    @width_sum += 1

    if @width_sum > Column::MAX_WIDTH
      @width_sum = 1

      return "</div><div class='form-group' style='text-align: right'>#{result}"
    else
      return result
    end
  end
end
