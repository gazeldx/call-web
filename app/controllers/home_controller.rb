class HomeController < ApplicationController
  def index
    @company_balance = current_company.charge_company.balance.round(0).to_i if user?
    render 'agent/home/index' if salesman?
  end

  def under_construction
  end
end