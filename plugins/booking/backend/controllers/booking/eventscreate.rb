module Backend::Controllers::Booking
  class Eventscreate
    include Api::Action

    expose :event

    def call(params)
      @event = Booking::Events::Event.new

      if request.post?
        booking.store(@event)
      end
    end
  end
end
