module Backend::Controllers::Booking
  class Eventsedit
    include Api::Action

    expose :event

    def call(params)
      @event = booking.events_all.find_or_create(params)
      pp @event
      if request.post?
        booking.store(@event)
      end
    end
  end
end
