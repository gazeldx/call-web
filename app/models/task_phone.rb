class TaskPhone < ActiveRecord::Base
  belongs_to :task

  # validates :phone, uniqueness: { scope: :task_id }

  # Company black numbers(All call methods never not call.)
  # Half black numbers(Task cannot call, can be called manually.)
  # Customers numbers(0 Inconvenience person not saved as Customer. Others will saved as Customer. For customers, task cannot call but can called manually.)
end
