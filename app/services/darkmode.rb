require "solareventcalculator.rb"

class Darkmode
  def self.darkmode?
    now = Time.zone.now
    # Wellington
    latitude = 41.2924
    longitude = 174.7787
    calc = SolarEventCalculator.new(Date.current, latitude, longitude)
    sunrise = calc.compute_official_sunrise("Pacific/Auckland")
    sunset = calc.compute_official_sunset("Pacific/Auckland")
    !now.between?(sunrise, sunset)
  end
end