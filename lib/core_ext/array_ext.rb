class Array
  def to_split
    self.to_s.gsub('"', '').sub('[', '').sub(']', '')
  end
end