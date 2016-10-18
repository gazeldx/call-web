class RechargesController < BaseController
  def index
    @recharges = current_company.recharges.page(params[:page]).order('created_at DESC')
  end
end
