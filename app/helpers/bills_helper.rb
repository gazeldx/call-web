module BillsHelper
  def bill_tr_props(bill)
    if bill.fee_type.id == FeeType::ID_FREEZE
      return { class: 'text-success' }
    elsif bill.fee_type.id == FeeType::ID_OUT_CHARGE
      return { class: 'text-primary' }
    else
      return {}
    end
  end
end
