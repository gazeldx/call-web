class BundlesController < BaseController
  include Bundles

  before_action :set_bundle, only: [:edit, :update, :stash, :destroy, :phones, :start]

  helper_method :bundle_kind

  def index
    @bundles = current_user.bundles.includes(:group, :tasks).where(kind: (bundle_kind == Bundle::KIND_IVR ? Bundle::IVR_MENUS.keys : bundle_kind), active: true)

    running_task_shown_at_top
  end

  def new
    current_company.bundle_kind = params[:kind]
    authorize(current_company,  :create_bundle?)

    @bundle = Bundle.new(kind: params[:kind])
  end

  def edit
    authorize(@bundle, :update?)
  end

  def create
    @bundle = current_company.bundles.build(bundle_params.merge(creator_id: session[:id],
                                                                number: params[:numbers].to_a.join(',')))

    current_company.bundle_kind = @bundle.kind
    authorize(current_company, :create_bundle?)

    if @bundle.save
      redirect_to index_path, notice: t('bundle.created')
    else
      render :new
    end
  end

  def update
    authorize(@bundle, :update?)

    if @bundle.update(bundle_params.merge(number: params[:numbers].to_a.join(',')))
      redirect_to index_path, notice: t('bundle.updated')
    else
      render :edit
    end
  end

  def stash
    authorize @bundle

    @bundle.tasks.before_running.each do |task|
      task.stash
    end

    @bundle.update_attributes(active: false)

    redirect_to index_path, notice: t('bundle.deleted')
  end

  # def destroy
  #   authorize @bundle
  #
  #   @bundle.destroy
  #
  #   redirect_to index_path, notice: t('bundle.deleted')
  # end

  def bundle_kind
    kind_to_path_hash.key(parse_controller_path(request.path_info)).to_i
  end

  private

  def running_task_shown_at_top
    @bundles.each do |bundle|
      bundle.tasks.each do |task|
        if task.running?
          bundle.created_at = Time.now # 用于页面排序，正在运行中的 bundle 排在顶部
          break
        end
      end
    end
  end

  def index_path
    kind_to_path_hash[@bundle.kind]
  end

  def set_bundle
    @bundle = Bundle.find(params[:id])
  end

  def bundle_params
    params.require(:bundle).permit(:name, :ratio, :kind, :number, :group_id, :remark, :manager_id)
  end
end
