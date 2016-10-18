module InvalidCdrsHelper
  KIND_COLOR = ['', 'grey', 'pink2', 'green', 'red', 'yellow', 'blue']

  def invalid_cdr_kind(kind)
    # content_tag(:span, t("invalid_cdr.kind_#{kind}"), class: KIND_COLOR[kind.to_i])
    content_tag(:span, '目前尚不明了', class: KIND_COLOR[kind.to_i])
  end
end
