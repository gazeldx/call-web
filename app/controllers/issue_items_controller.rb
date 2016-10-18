class IssueItemsController < BothController
  def create
    @issue = Issue.find(issue_item_params[:issue_id])

    @issue_item = IssueItem.new(issue_item_params.merge(company_id: current_company.id,
                                                        creator_id: session[:id],
                                                        creator_type: session[:salesman] ? Issue::CREATOR_TYPE_SALESMAN : Issue::CREATOR_TYPE_USER,
                                                        handler_id: @issue.handler_id,
                                                        handler_type: @issue.handler_type,
                                                        state: @issue.state))

    authorize(@issue_item)

    @issue.handler_id = issue_item_params[:handler_id][1..-1]
    @issue.handler_type = issue_item_params[:handler_id][0] == 's' ? Issue::CREATOR_TYPE_SALESMAN : Issue::CREATOR_TYPE_USER
    @issue.state = issue_item_params[:state]

    authorize(@issue)

    @issue_item.save_with_issue!(@issue)

    redirect_to issue_path(@issue), notice: "#{t('issue_item.created', w: current_user.name)} #{@issue.publish_to_handler}"
  end

  private

  def issue_item_params
    params.require(:issue_item).permit(:issue_id, :body, :state, :handler_id)
  end
end
