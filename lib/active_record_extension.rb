module ActiveRecordExtension
  extend ActiveSupport::Concern

  # add your instance methods here
  def checkbox_name
    "&nbsp;#{self.name}&nbsp;&nbsp;&nbsp;&nbsp;".html_safe
  end

  # add your static(class) methods here
  module ClassMethods
    #E.g: Order.top_ten
    # def top_ten
    #   limit(10)
    # end
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)