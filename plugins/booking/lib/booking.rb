require_relative "booking/booking"
require_relative "booking/events"
require_relative "booking/calendar"
require_relative "booking/workdays"
require_relative "booking/database"

%w"controllers views".each do |parent_dir|
  target_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../", parent_dir)
  Dir.glob("%s/**/*.rb" % target_dir).each do |tf|
    begin
      Habitat._require tf

    rescue
      p $!
    end
  end
end


if Habitat.quart
  Habitat.add_adapter(:booking, Booking::Database.with_adapter.new(Habitat.quart.media_path))  
end
