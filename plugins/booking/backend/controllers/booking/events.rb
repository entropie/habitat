module Backend::Controllers::Booking
  class Events
    include Api::Action

    expose :events

    def call(params)
      @events = booking.events(year: 2021, month: nil)
    end
  end
end

