require_relative "database"
require_relative "post"

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

  module ControllerMethods

    def tumblog(&blk)
      Habitat.adapter(:tumblog).with_user(session_user, &blk)
    end

    def check_token(params)
      @return = {}
      if params[:token]
        @token_user = Habitat.adapter(:user).by_token(params[:token])
      else
        @return[:ok] = :nope
      end
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
