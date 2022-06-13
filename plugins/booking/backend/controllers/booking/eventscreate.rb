module Backend::Controllers::Booking
  class Eventscreate
    include Backend::Action

    expose :event

    def call(params)
      @event = Booking::Events::Event.new

      if request.post?
        # first create event and save it so we have a proper set up instance for image upload
        phash = params.to_hash
        imgh = { :image => phash.delete(:image)}

        event = booking.create(:event, phash)
        event = booking.update(event, imgh) if imgh[:image]
        @event = event
      end
    end
  end
end
