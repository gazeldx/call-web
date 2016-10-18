class GroupsController < BaseController
  before_action :set_group, only: [:edit, :update, :destroy]

  def index
    if current_user.admin?
      @groups = current_company.groups.state_ok
    else
      @groups = current_company.groups.outbound
    end

    @groups = @groups.includes(:users, [agents: [:extensions, :salesman]]).order('created_at').page(params[:page])
  end

  def new
    @group = Group.new({ outbound: true, spill: true, timeout: true }.merge(default_values))
  end

  def edit
    @group.set_default_values(default_values)
  end

  def create
    @group = current_company.groups.build(group_params)

    authorize @group

    if @group.save
      unless @group.outbound?
        AgentsGroups.where(group_id: @group.id).update_all(level: AgentsGroups::LEVEL_MEDIUM)
      end

      RedisHelp.add_group(@group)

      redirect_to groups_path, notice: t('group.created')
    else
      render :new
    end
  end

  def update
    authorize current_company.groups.build(group_params.merge(id: @group.id))

    old_agent_ids = @group.agents.pluck(:id)
    new_agent_ids = group_params[:agent_ids].reject { |x| x == '' }.map(&:to_i)

    agents_to_remove = Agent.find(old_agent_ids - new_agent_ids)

    agents_to_add = Agent.find(new_agent_ids - old_agent_ids)

    busy_agents = RedisHelp.busy_agents(@group, agents_to_remove)

    if busy_agents.present?
      flash[:error] = "本次操作被系统拒绝处理，原因是“分机号为#{busy_agents[0].extension_names}的座席正处于通话忙碌状态，而您试图把该座席从本组中移除。”"
      render :edit
    else
      if group_params[:agent_ids].blank? # validates :agents, length: { minimum: 1, message: I18n.t(:at_least_has_one) } # 这是Rails的一个Bug，因为rails这种情况表现为仅对create的时候有效，而update的时候是无效的。这是不正确的。所以这里我加入了agent_ids是否是blank?的判断了。
        flash[:error] = "本次操作被系统拒绝处理，原因是座席未选择。请至少选择一个座席。"
        render :edit
      else
        if @group.update(group_params.merge(group_params[:max_wait_time].nil? ? { max_wait_time: Group::DEFAULT_MAX_WAIT_TIME } : {}))
          RedisHelp.update_group(@group, agents_to_remove, agents_to_add)

          redirect_to groups_path, notice: t('group.updated')
        else
          render :edit
        end
      end
    end
  end

  def up_agent_inbound_level
    #TODO: Authorize
    agent_group = AgentsGroups.find_by_agent_id_and_group_id(params[:agent_id], params[:group_id])

    if [AgentsGroups::LEVEL_LOW, AgentsGroups::LEVEL_MEDIUM].include?(agent_group.level)
      RedisHelp.set_agent_inbound_level(params[:agent_id], params[:group_id], agent_group.level + 1, agent_group.level)

      agent_group.update_attributes!(level: agent_group.level + 1)
    end

    redirect_to groups_path, notice: t('group.agent_level_success')
  end

  def down_agent_inbound_level
    #TODO: Authorize
    agent_group = AgentsGroups.find_by_agent_id_and_group_id(params[:agent_id], params[:group_id])

    if [AgentsGroups::LEVEL_HIGH, AgentsGroups::LEVEL_MEDIUM].include?(agent_group.level)
      RedisHelp.set_agent_inbound_level(params[:agent_id], params[:group_id], agent_group.level - 1, agent_group.level)

      agent_group.update_attributes!(level: agent_group.level - 1)
    end

    redirect_to groups_path, notice: t('group.agent_level_success')
  end

  def destroy
    authorize @group

    if @group.cannot_destroy_reason.present?
      flash[:error] = @group.cannot_destroy_reason
    else
      @group.destroy
      flash[:notice] = t('group.deleted')
    end

    redirect_to groups_path
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :outbound, :spill, :spill_count, :play_spill_voice, :spill_ivr_id, :timeout, :max_wait_time, :play_timeout_voice, :max_loop_times, :timeout_ivr_id, agent_ids: [], user_ids: [])
  end

  def default_values
    { spill_count: 3, play_spill_voice: true, max_wait_time: Group::DEFAULT_MAX_WAIT_TIME, play_timeout_voice: true, max_loop_times: Group::DEFAULT_MAX_LOOP_TIMES }
  end
end
