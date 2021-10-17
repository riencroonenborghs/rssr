class Darkmode
  def self.darkmode?
    now = Time.zone.now
    seven_am = now.beginning_of_day + 7.hours
    seven_pm = now.beginning_of_day + 19.hours
    !now.between?(seven_am, seven_pm)
  end
end