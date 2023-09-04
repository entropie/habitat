module Backend::Controllers::Booking
  class Eventarchive
    include Backend::Action

    def call(params)
      @event = booking.events_all.find_or_create(params)

      booking.archive(@event)
      redirect_to Backend.routes.events_path
    end
  end
end
