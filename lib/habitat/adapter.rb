module Habitat

  class Adapter < Hash
  end

  module Database

    class DataBaseError < StandardError; end
    class NotImplemented < DataBaseError; end
    class NotAuthorized < DataBaseError; end
    class NoUserContext < NotAuthorized; end      

    class EntryNotValid < DataBaseError; end      

    def self.get_random_id
      ary = [*'a'..'z', *'A'..'Z', *0..9].shuffle(random: SecureRandom.hex(23).to_i(16))
      enum = ary.permutation(32)
      enum.next.join
    end

    def adapter
      @adapter ||= const_get(self.to_s.split("::").first).const_get(:DEFAULT_ADAPTER)
    end
    
    def adapter=(obj)
      @adapter = obj
    end

    def with_adapter(adpt = adapter)
      const_get(:Adapter).const_get(adpt.to_s.capitalize.to_sym)
    end

    class Adapter

      NOT_IMPLMENTED_MSG = "not implemented in parent class; use corresponding subclass instead".freeze

      attr_reader :user

      def log(w, msg)
        if Object.constants.include?(:Habitat)
          Habitat.log(w, msg)
        else
          puts "DIARY> #{msg}"
        end
      end
    
      def setup
        raise NotImplemented, NOT_IMPLMENTED_MSG
      end

      def query(*_)
        raise NotImplemented, NOT_IMPLMENTED_MSG
      end

      def upload(sheet, params)
        raise NotImplemented, NOT_IMPLMENTED_MSG        
      end

      def adapter_class
        raise "can only be called by subclass of Habitat::Database::Adapter"
      end

      def create(param_hash)
        adapter_class.populate(param_hash)
      end

      def without_user(&blk)
        bkup = @user; @user = nil
        yield self
        @user = bkup
      end
    end
  end

end
