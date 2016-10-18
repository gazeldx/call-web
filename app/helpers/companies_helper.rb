module CompaniesHelper
  def enabled_or_disabled(model)
    if model.active
      content_tag(:span, t('enabled'), class: 'label label-sm label-success')
    else
      content_tag(:span, t('disabled'), class: 'label label-sm label-inverse')
    end
  end

  def company_state_info(company)
    css = ['', 'success', 'warning', 'danger'].map do |color|
      "label label-sm label-#{color}"
    end

    raw(content_tag(:span, t("company.state_#{company.state}"), class: css[company.state]))
  end
end
