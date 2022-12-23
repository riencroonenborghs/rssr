# frozen_string_literal: true

class Offset
  def self.to_offset(datetime: Time.zone.now)
    datetime.to_i.to_s(16).upcase
  end

  def self.to_datetime(offset:)
    Time.at("0x#{offset}".hex).to_datetime.in_time_zone("Pacific/Auckland")
  end
end
