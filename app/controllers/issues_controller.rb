class IssuesController < BothController
  include Search

  before_action :has_issue_management?
  before_action :set_issue, only: [:show, :popup]

  def index
    @issues = current_company.issues

    @issues = equal_search(@issues, [:id, :state, :handler_id, :creator_id])

    @issues = like_search(@issues, [:title])

    @issues = @issues.includes(:issue_items).page(params[:page]).order(id: :desc)
  end

  def show
    authorize(@issue)

    new_issue_item
  end

  def new
    @issue = Issue.new(state: Issue::STATE_NOT_HANDLED)
  end

  def create
    @issue = current_company.issues.build(issue_params.merge(creator_id: session[:id],
                                                             creator_type: session[:salesman] ? Issue::CREATOR_TYPE_SALESMAN : Issue::CREATOR_TYPE_USER,
                                                             handler_id: issue_params[:handler_id][1..-1],
                                                             handler_type: issue_params[:handler_id][0] == 's' ? Issue::CREATOR_TYPE_SALESMAN : Issue::CREATOR_TYPE_USER))

    authorize(@issue)

    if @issue.save
      redirect_to issues_path, notice: "#{t('issue.created', w: current_user.name)} #{@issue.publish_to_handler}"
    else
      render :new
    end
  end

  def popup
    authorize(@issue)

    new_issue_item

    render :show, layout: 'bone'
  end

  private

  def has_issue_management?
    redirect_to root_path unless current_company.have_menu?('issue.management')
  end

  def set_issue
    @issue = Issue.find(params[:id])
  end

  def issue_params
    params.require(:issue).permit(:title, :body, :state, :handler_id)
  end

  def new_issue_item
    @issue_item = IssueItem.new(issue_id: @issue.id,
                                state: @issue.state,
                                handler_id: @issue.handler_id,
                                handler_type: @issue.handler_type)
  end
end
