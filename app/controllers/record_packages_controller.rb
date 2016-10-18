class RecordPackagesController < BaseController
  before_action :set_record_package, only: [:edit, :update]

  def index
    @record_packages = current_company.record_packages.page(params[:page]).order('created_at DESC')
  end

  def edit
    set_return_to
  end

  def update
    authorize @record_package

    if @record_package.update(record_package_params)
      flash[:notice] = t('record_package.updated', id: @record_package.id)
      return_to
    else
      render :edit
    end
  end

  private

  def set_record_package
    @record_package = RecordPackage.find(params[:id])
  end

  def record_package_params
    params.require(:record_package).permit(:title)
  end
end
