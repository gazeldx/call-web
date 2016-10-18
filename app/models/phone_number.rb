class PhoneNumber < ActiveRecord::Base
  belongs_to :company

  scope :task_numbers, -> { where(for_task: true).order(:created_at) }

  scope :agent_numbers, -> { where(for_agent: true).order(:created_at) }

  def self.sync_numbers(params)
    logger.info params.inspect

    params[:numbers].each_with_index do |param, i|
      logger.info "====== sync_number [#{i}]: #{param} ======"
      if param[:method] == 'add'
        unless PhoneNumber.exists?(company_id: param[:tenant_id], number: param[:number])
          PhoneNumber.create!(company_id: param[:tenant_id],
                              number: param[:number],
                              for_task: ['tasks', 'both'].include?(param[:purpose]),
                              for_agent: ['agents', 'both'].include?(param[:purpose]),
                              expire_at: param[:expire_at],
                              validity_hours: param[:validity].to_i)

          RedisHelp.set_caller_number(param[:tenant_id], param[:number], param[:expire_at])
        end
      elsif param[:method] == 'update'
        phone_numbers = PhoneNumber.where(number: param[:number])

        unless phone_numbers.blank?
          phone_numbers.update_all(for_task: ['tasks', 'both'].include?(param[:purpose]),
                                   for_agent: ['agents', 'both'].include?(param[:purpose]),
                                   expire_at: param[:expire_at],
                                   validity_hours: param[:validity].to_i)

          phone_numbers.each do |number|
            RedisHelp.set_caller_number(number.company_id, param[:number], param[:expire_at])
          end
        end
      elsif param[:method] == 'delete'
        phone_number = PhoneNumber.find_by_number_and_company_id(param[:number], param[:tenant_id])

        phone_number.try(:destroy)

        RedisHelp.del_caller_number(param[:tenant_id], param[:number])
      end
    end
  end

  def implode
    RedisHelp.del_caller_number(self.company_id, self.number)
    self.destroy
  end

  def expired?
    self.expire_at < Time.now
  end

  def checkbox_number
    "&nbsp;#{self.number}&nbsp;&nbsp;&nbsp;&nbsp;".html_safe
  end
end
