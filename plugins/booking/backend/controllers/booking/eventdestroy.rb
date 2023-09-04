module Backend::Controllers::Booking
  class Eventdestroy
    include Backend::Action

    def call(params)
      @event = booking.events_all.find_or_create(params)

      # try from archive when not exit
      unless @event.exist?
        @event = booking.events_archived.select{ |ev| ev.slug == params[:slug] }.shift
      end

      booking.destroy(@event)
      redirect_to Backend.routes.events_path
    end
  end
end
