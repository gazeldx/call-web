module TeamsHelper
  def teams_checkbox(form)
    # TODO: 这里有一个bug,就是current_company.users.order('name')其实并不能按照汉字的拼音来排序。需要进一步处理下。
    content_tag(:div,
                labeled(:teams) + content_tag(:div,
                                              form.collection_check_boxes(:team_ids, current_company.teams.order(:id), :id, :checkbox_name),
                                              class: 'col-sm-9'),
                class: 'form-group')
  end

  def search_teams_checkbox
    if current_user.manage_many_teams?
      content_tag(:th, raw("#{t(:team_)}#{checkbox_for_search(:team_id)}"), class: 'red', 'data-content' => '根据团队搜索，数据只反映当前团队，并不反映过去这个团队的情况。<br>比如现在你把张三从团队A转移到团队B，张三的全部历史数据都归结为团队B，不再是团队A。<br>所以请及时做好当期的报表数据导出，否则在您作了人员的调整后，历史的统计就不准确了。', 'data-trigger' => 'hover', 'data-rel' => 'popover', 'data-html' => 'true')
    end
  end
end
