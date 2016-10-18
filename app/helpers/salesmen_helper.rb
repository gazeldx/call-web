module SalesmenHelper
  def salesmen_checkbox(form)
    # TODO: 这里有一个bug,就是current_company.users.order('name')其实并不能按照汉字的拼音来排序。需要进一步处理下。
    content_tag(:div,
                labeled(:salesmen, required: true) + content_tag(:div,
                                               form.collection_check_boxes(:salesman_ids, current_company.salesmen.where("team_id is null OR team_id=?", @team.id).order(:name), :id, :checkbox_name),
                                               class: 'col-sm-9'),
                class: 'form-group')
  end

  def salesman_active(salesman)
    if salesman.active?
      content_tag(:span, t('salesman.active_true'), class: 'label label-sm label-info')
    else
      content_tag(:span, t('salesman.active_false'), class: 'label label-sm label-default')
    end
  end
end
