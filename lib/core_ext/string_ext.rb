class String
  def file_extension_type
    self[self.rindex('.') + 1..self.length]
  end

  def with_zero_prefix
    if self.length == 1
      "0#{self}"
    else
      self
    end
  end

  def hide_middle_digits
    md = self.match(/\d{3}(\d{4})/)
    md_1 = md.try(:[], 1)

    md_1.nil? ? self : self.sub(md_1, '****')
  end
end