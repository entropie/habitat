module Booking
  class Events::Event
    class Attender < Hash

      attr_reader :slot, :slug

      def self.load_for(event)
        files = Dir.glob(event.attender_path + "/*.yaml")
        files.map { |f| YAML::load_file(f) }
      end

      def initialize(event_slug, attender_hash, slot)
        ah = Events::Event.normalize_params(attender_hash)
        merge!(ah)
        @slot, @slug = slot, event_slug
      end

      def event
        Habitat.adapter(:booking).by_slug(slug)
      end

      def datahash
        Digest::SHA1.hexdigest( [:contact,:message].map{ |k| self[k].to_s }.join)[0..11]
      end

      def filename
        File.join(event.attender_path, "%s.yaml" % datahash)
      end
    end
  end
end

