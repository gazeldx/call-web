class Agent::ContactsController < SalesmanBaseController
  def create_contact
    set_customer

    #TODO: task_id cdr_id cdr.call_type
    @contact = @customer.contacts.build(phone: @customer.s1,
                                        remark: params[:remark],
                                        company_id: @customer.company.id,
                                        salesman_id: session[:id],
                                        agent_id: current_user.agent.try(:id))

    if @contact.save
      @customer.update_attribute(:updated_at, Time.now)

      render json: { result: t('contact.saved') }
    else
      render json: { result: t('contact.save_failed') }
    end
  end

  def index
    @contacts = current_user.contacts.includes(:customer, :agent).order('id DESC').page(params[:page])
  end

  private

  def set_customer
    @customer = Customer.find(params[:customer_id])
  end
end
