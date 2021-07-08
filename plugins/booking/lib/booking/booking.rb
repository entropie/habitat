module Booking
  DEFAULT_ADAPTER = :File

  module BookingViewMethods
  end

  module BookingControllerMethods
    def booking
      Habitat.adapter(:booking)
    end

    def events(year = Time.now.strftime("%y"), month = Time.now.strftime("%m"))
      booking.events(year: year, month: month)
    end
  end
end
