module Booking
  class Events::Event
    class Attender < Hash

      def self.load_for(event)
        files = Dir.glob(event.attender_path + "/*.yaml")
        files.map { |f| YAML::load_file(f) }
      end

      def initialize(event_slug, attender_hash, slot)
        ah = Events::Event.normalize_params(attender_hash)
        self[:created_at] = Time.now
        self[:slot] = slot
        self[:slug] = event_slug
        merge!(ah)
      end

      def slug
        self[:slug]
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

