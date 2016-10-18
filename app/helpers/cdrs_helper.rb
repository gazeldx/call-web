module CdrsHelper
  def call_type_name(cdr)
    css = ['danger', 'warning', 'primary', 'default', 'success', 'purple'].map do |color|
      "label label-sm label-#{color}"
    end

    raw(content_tag(:span, t("cdr.call_type_#{cdr.call_type}"), class: css[cdr.call_type]))
  end

  def download_audio(url)
    content_tag(:a, icon('cloud-download'), { href: url, class: 'pink2' }.merge(tip('download_record'))) + ' '
  end

  def download_record_path(cdr_id)
    "/cdr/download_record/#{cdr_id}"
  end

  def cdr_time_info(cdr)
    if cdr.answer_stamp.present?
      content = content_tag(:span, cdr.answer_stamp.strftime(t('time_without_year')), class: 'green')
    else
      content = cdr.start_stamp.strftime(t('time_without_year'))
    end
    content_tag(:td, content, 'data-content' => "#{'呼叫发起：' + cdr.start_stamp.strftime(t('time_without_year'))}<br>#{'接通时间：' + cdr.answer_stamp.strftime(t('time_without_year')) + '<br>' if cdr.answer_stamp.present?}#{'挂断时间：' + cdr.end_stamp.strftime(t('time_without_year'))}", 'data-trigger' => 'hover', 'data-rel' => 'popover', 'data-placement' => 'right', 'data-html' => 'true')
  end

  def group_report_cdrs
    result = raw("&nbsp;")
    if SystemConfig.free_time?
      result << content_tag(:button, t('cdr.group_report'), type: 'submit', class: 'hidden_when_submit btn btn-success btn-sm', id: 'group_report_button', onclick: "$('#target_method').val('group_report');")
    else
      result << content_tag(:button, t('cdr.group_report'), type: 'button', class: 'hidden_when_submit btn btn-default btn-sm', 'data-title' => t(:operate_at_free_time), 'data-rel' => 'tooltip', onclick: "alert('#{t(:operate_at_free_time)}')")
    end
    result
  end

  def package_cdrs_records
    if policy(:record_package2).download?
      result = raw("&nbsp;")
      if @cdrs.count > max_package_records_cdrs_count
        result << content_tag(:button, t('record.package'), type: 'button', class: 'hidden_when_submit btn btn-default btn-sm', 'data-title' => "一次打包的录音数量过多！请控制话单数量在#{max_package_records_cdrs_count}以内。", 'data-rel' => 'tooltip')
      else
        result << package_records_button
      end
    end
  end

  def batch_mixin_records
    if policy(:record_package2).download?
      result = raw("&nbsp;")
      if @cdrs.count > max_package_records_cdrs_count
        result << content_tag(:button, t('record.batch_mixin'), type: 'button', class: 'hidden_when_submit btn btn-default btn-sm', 'data-title' => "需要合成的录音数量过多！请控制话单数量在#{max_package_records_cdrs_count}以内。", 'data-rel' => 'tooltip')
      else
        result << batch_mixin_record_button
      end
    end
  end

  def export_cdr_button
    result = raw("&nbsp;")
    if SystemConfig.free_time? || Company::BANK_UNION_DATA_IDS.include?(current_company.id) || @cdrs.count <= Cdr::MAX_EXPORT_COUNT_ON_BUSY_TIME
      result << export_button
    else
      result << content_tag(:button, t(:export_result), type: 'button', class: 'hidden_when_submit btn btn-default btn-sm', id: 'export_button', 'data-content' => "话单数量在#{Cdr::MAX_EXPORT_COUNT_ON_BUSY_TIME}条以内可以直接导出。本次要导出的话单数超过了#{Cdr::MAX_EXPORT_COUNT_ON_BUSY_TIME}条，请分多次导出，每次控制话单数在#{Cdr::MAX_EXPORT_COUNT_ON_BUSY_TIME}条以内；或者如果您想一次导完，#{t(:operate_at_free_time)}", 'data-rel' => 'popover', 'data-trigger' => 'hover', 'data-placement' => 'top', 'data-html' => 'true', onclick: "alert('#{t(:operate_at_free_time)}')")
    end
    result
  end

  def exist_need_mixin_record?(record_path_array)
    record_path_array.to_a.any? { |record_path| !audio_extension_file?(record_path) }
  end
end
