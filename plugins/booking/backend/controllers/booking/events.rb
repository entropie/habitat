module Backend::Controllers::Booking
  class Events
    include Api::Action

    expose :events

    def call(params)
      @events = events
    end
  end
end
