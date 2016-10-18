class ContactsController < BaseController
  def create_contact
    set_customer

    #TODO: task_id cdr_id cdr.call_type
    @contact = @customer.contacts.build(phone: @customer.s1,
                                        remark: params[:remark],
                                        company_id: current_company.id)

    if @contact.save
      @customer.update_attribute(:updated_at, Time.now)

      render json: { result: t('contact.saved') }
    else
      render json: { result: t('contact.save_failed') }
    end
  end

  # TODO: 可能已经不用了，可以清理掉
  def index
    @contacts = current_company.contacts.includes(:customer, :agent, :salesman).order('id DESC').page(params[:page])
  end

  private

  def set_customer
    @customer = Customer.find(params[:customer_id])
  end
end
