module Backend::Controllers::Booking
  class Eventdestroy
    include Backend::Action

    def call(params)
      @event = booking.events_all.find_or_create(params)

      @event = booking.update(@event, params)
      booking.destroy(@event)
      redirect_to Backend.routes.events_path
    end
  end
end
