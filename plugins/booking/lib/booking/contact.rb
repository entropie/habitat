module Booking
  class Contact

    extend Habitat::Mixins::FU

    class ContactMSG < Hash
      def initialize
        self[:created_at] = Time.now
      end

      def datahash
        Digest::SHA1.hexdigest( [:contact,:message].map{ |k| self[k].to_s }.join)[0..11]
      end

      def filename
        Habitat.adapter(:booking).repository_path("contact", "%s.yaml" % datahash)
      end
    end

    def self.create(params)
      cmsg = ContactMSG.new
      cmsg.merge!(Booking::Events::Event.normalize_params(params))
      write(cmsg.filename, YAML::dump(cmsg))
      cmsg
    end
    
  end
end
