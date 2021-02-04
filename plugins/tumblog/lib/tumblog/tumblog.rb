require_relative "database"
require_relative "post"
require_relative "api"

module BackgroundJob
  def self.anytime(&blk)
    blk.call
    true
  end

  def self.handle_input(content, user)

  end
end


module Tumblog

  DEFAULT_ADAPTER = :File

  def self.token=(tknstr)
    @token = tknstr.strip
  end

  def self.token
    @token
  end

  module ControllerMethods

    def tumblog(&blk)
      Habitat.adapter(:tumblog).with_user(session_user, &blk)
    end
  end

  class HandleInput
    def perform(content, user)
    end
  end



  
end

if Habitat.quart
  Habitat.add_adapter(:tumblog, Tumblog::Database.with_adapter.new(Habitat.quart.media_path))  
end
