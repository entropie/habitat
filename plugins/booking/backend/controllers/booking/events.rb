module Backend::Controllers::Booking
  class Events
    include Backend::Action

    expose :events, :pager

    def call(params)
      @events = booking.events_all
                  .sort_by{ |ev| ev.start_date }.reverse

      @pager = Pager::BackendPager.new(params, @events, 10)
      @pager.link_proc = -> (n) { routes.eventsPager_path(n) } 
    end
  end
end

