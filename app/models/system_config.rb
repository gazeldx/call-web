class SystemConfig
  def self.free_time?
    Time.now < Time.parse('09:00', Time.now) ||
    (Time.now > Time.parse('12:00', Time.now) && Time.now < Time.parse('13:00', Time.now)) ||
    Time.now > Time.parse('18:00', Time.now)
  end
end
