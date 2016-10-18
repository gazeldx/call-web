module IssuePerson
  def handler
    if self.handler_type == Issue::HANDLER_TYPE_USER
      User.find(self.handler_id)
    elsif self.handler_type == Issue::HANDLER_TYPE_SALESMAN
      Salesman.find(self.handler_id)
    end
  end

  def creator
    if self.creator_type == Issue::CREATOR_TYPE_USER
      User.find(self.creator_id)
    elsif self.creator_type == Issue::CREATOR_TYPE_SALESMAN
      Salesman.find(self.creator_id)
    end
  end
end
