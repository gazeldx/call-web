module UsersHelper
  def users_checkbox(form)
    # TODO: 这里有一个bug,就是current_company.users.order('name')其实并不能按照汉字的拼音来排序。需要进一步处理下。
    content_tag(:div,
                labeled(:users, required: true) +
                  content_tag(:div, form.collection_check_boxes(:user_ids, current_company.users.order(:name), :id, :checkbox_name), class: 'col-sm-9'),
                class: 'form-group')
  end
end
