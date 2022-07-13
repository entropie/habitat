module Spoolnotif

  DEFAULT_SPOOL_SIZE = 20

  def self.spooler_size
    @spooler_size || DEFAULT_SPOOL_SIZE
  end

  def self.spooler_size=(number)
    @spooler_size = number
  end
  
  def self.spooler
    @spooler ||= MessageSpooler.new
  end

  def self.clear
    @spooler = MessageSpooler.new
  end

  def self.unspooler
    @unspooler ||= proc {

      if Habitat.quart.plugins.enabled?(:notify)
        messages = spooler.inject(""){ |ret, msg|
          ret << msg.to_s << "\n"
          ret
          
        }
        Notify::notify(subject: "Spooler collected #{self.spooler_size} messages",
                       body:    "%s" % messages)
      else

        Habitat.log :error, "no unspooler set, doing basicially nothing but printing to $stdout"
        spooler.each do |msg|
          puts msg.to_s
        end
      end
      clear
    }
  end

  def self.unspooler=(blk)
    @unspooler = blk
  end

  class MessageSpooler < Array

    class Notification
      attr_accessor :timestamp, :message, :from

      def initialize(message, from)
        self.timestamp = Time.now
        self.message = message
        self.from = from
      end

      def to_s
        "(Spoolmsg:#{from}:#{timestamp.to_s}:\n#{message})"
      end
    end


    
    def push(*args)
      super(Notification.new(*args))
    end
  end

  def self.<<(*args)
    spooler.push(*args.flatten)

    if spooler.size >= Spoolnotif.spooler_size
      unspooler.call
    end
  end
end
