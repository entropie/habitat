module Backend::Controllers::Booking
  class Eventscreate
    include Api::Action

    expose :event

    def call(params)
      @event = Booking::Events::Event.new

      if request.post?
        @event = booking.create(:event, params)
      end
    end
  end
end
