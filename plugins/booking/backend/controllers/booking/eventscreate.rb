module Backend::Controllers::Booking
  class Eventscreate
    include Api::Action

    expose :event

    def call(params)
      @event = ::Booking::Events::Event.new
    end
  end
end
