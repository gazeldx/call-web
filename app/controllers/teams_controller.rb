class TeamsController < BaseController
  before_action :set_team, only: [:edit, :update, :destroy]

  def index
    @teams = current_company.teams.includes(:users).order(:id).page(params[:page])
  end

  def new
    @team = Team.new
  end

  def edit
  end

  def create
    @team = current_company.teams.build(team_params)

    authorize @team

    if @team.save
      redirect_to teams_path, notice: t('team.created')
    else
      render :new
    end
  end

  def update
    authorize current_company.teams.build(team_params.merge(id: @team.id))

    if @team.update(team_params)
      redirect_to teams_path, notice: t('team.updated')
    else
      render :edit
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, salesman_ids: [], user_ids: [])
  end
end