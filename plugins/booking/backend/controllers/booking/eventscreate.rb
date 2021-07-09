module Backend::Controllers::Booking
  class Eventscreate
    include Api::Action

    expose :event

    def call(params)
      @event = booking.events.find_or_create(params)
      if request.post?
        booking.store(@event)
      end
    end
  end
end
