module Backend::Controllers::Booking
  class Eventdestroy
    include Api::Action

    def call(params)
      @event = booking.events_all.find_or_create(params)

      @event = booking.update(@event, params)
      booking.destroy(@event)
      redirect_to Backend.routes.eventsPath
    end
  end
end
