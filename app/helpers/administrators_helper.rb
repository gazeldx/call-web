module AdministratorsHelper
  def administrator_kind(kind)
    raw(content_tag(:span, t("administrator.kind_#{kind.to_s}"), class: ['success', 'primary', 'danger'].map { |color| "label label-sm label-#{color}" }[kind.to_i]))
  end
end
