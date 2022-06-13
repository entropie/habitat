module Backend::Controllers::Booking
  class Eventtogglepublish
    include Backend::Action

    def call(params)
      @event = booking.events_all.find_or_create(params)
      if @event.published? then @event.unpublish! else @event.publish! end

      booking.store(@event)
      redirect_to params[:url]
      @event
    end
  end
end
