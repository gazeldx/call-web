module RecordFormatsHelper
  def record_formats_description
    if current_company.record_formats.blank?
      format = "贵公司当前采用的是默认的录音格式：#{t('record_format.calleeNumber')}_#{t('record_format.date')}"
    else
      format = current_company.record_formats.order(:id).map { |record_format| t("record_format.#{record_format.name}") }.join('_')
    end
    format + '.mp3'
  end

  def record_formats_sample
    if current_company.record_formats.blank?
      sample = "#{t('record_format.calleeNumber_sample')}_#{t('record_format.date_sample')}"
    else
      sample = current_company.record_formats.order(:id).map { |record_format| t("record_format.#{record_format.name}_sample") }.join('_')
    end
    sample + '.mp3'
  end

  def record_formats_with_operations
    raw(current_company.record_formats.order(:id).map do |record_format|
      t("record_format.#{record_format.name}") + link_to('移除', "record_formats/remove_#{record_format.name}", title: "点击后，录音文件名将不再包括“#{t("record_format.#{record_format.name}")}”", 'data-rel' => 'tooltip')
    end.join('_') + '.mp3')
  end
end