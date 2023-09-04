module Backend::Controllers::Booking
  class Eventsarchived
    include Backend::Action

    expose :events, :pager

    def call(params)

      @events = booking.events_archived
      @pager = Pager::BackendPager.new(params, @events, 10)
      @pager.link_proc = -> (n) { routes.eventsPager_path(n) } 

    end
  end
end
