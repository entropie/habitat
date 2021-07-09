module Booking
  DEFAULT_ADAPTER = :File

  module BookingViewMethods
  end

  module BookingControllerMethods
    def booking
      Habitat.adapter(:booking).with_user(session_user)
    end

  end
end
