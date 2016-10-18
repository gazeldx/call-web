class Agent::CdrsBaseController < SalesmanBaseController
  include Cdrs, Search

  def index
    authorize(:cdr2, :view?)
  end

  def search
    authorize(:cdr2, :view?)

    if params[:start_stamp_day]
      @cdrs = current_user.try(controller_name.to_sym).where(company_id: current_user.company_id) # company_id这个条件要加, 否则company_id和start_stamp的联合索引就用不到了

      search_start_stamp

      @cdrs = equal_search(@cdrs, [:agent_id, :call_type])

      @cdrs = like_search(@cdrs, [:callee_number, :caller_number])

      search_duration

      search_call_lose

      @cdrs = @cdrs.order('start_stamp DESC').includes(:task).page(params[:page])
    end

    render :index
  end

  def customer_cdrs_json(customer, cdrs)
    cdrs.where(callee_number: customer.s1).includes(:salesman, :task, :agent).order(start_stamp: :desc)
        .as_json(only: [:id, :start_stamp, :call_type, :caller_number, :callee_number, :duration, :cost, :agent_id, :salesman_id, :record_url],
                 methods: [:duration_as_words, :call_type_name, :start_stamp_formatted],
                 include: { salesman: { only: :name }, agent: { only: :code } })
  end
end
