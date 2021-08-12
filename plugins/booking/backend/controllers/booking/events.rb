module Backend::Controllers::Booking
  class Events
    include Api::Action

    expose :events, :pager

    def call(params)
      @events = booking.events_all
      @pager = Pager::BackendPager.new(params, @events, 10)
      @pager.link_proc = -> (n) { routes.eventsPager_path(n) } 
    end
  end
end

