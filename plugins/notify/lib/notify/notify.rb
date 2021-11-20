require "pony"

module Notify

  def notify(*args)
    default_notifier.notify(*args)
  end
  module_function :notify

  def default_notifier=(obj)
    @default_notifier = obj
  end

  def default_notifier
    @default_notifier ||= Notifier.notify_modules.first
  end
  module_function :default_notifier, :default_notifier=
  


  class Notifier

    def self.app_subject(str)
      "[%s] #{str}" % [ Habitat.quart.identifier ]
    end

    def self.notify_modules
      @notify_modules ||= []
    end

    def self.inherited(obj)
      notify_modules << obj
    end

    def initialize
    end
  end

  class Notify::Test < Notify::Notifier
    def self.notify(subject: "", body: "")
      :test
    end
  end

end
