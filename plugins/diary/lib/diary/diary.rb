# coding: utf-8
#
#

require 'digest/sha1'
require 'securerandom'
require 'yaml'

require_relative "renderer"
require_relative "database"
require_relative "sheets"
require_relative "references"


module Diary

  DEFAULT_ADAPTER = :File

  module ApiControllerMethods
    def self.included(o)
      o.instance_eval do
        before :check_token
      end

      def A(*args, &blk)
        adapter_with_usercontext(:diary, *args, &blk)
      end
    end

    private
    def check_token(params)
      @return = {}
      if params[:token]
        @token_user = Users.by_token(params[:token])
      else
        @return[:ok] = :nope
      end
    end
  end

  
  class Diaries < Array
  end
  
  def self.db(adapter = Database.adapter)
    @db ||= Database.with_adapter(adapter)
  end


  def self.log(str)
    if Object.const_defined?(:Habitat)
      Habitat.log(:debug, str)
    else
      puts " >>> #{str}"
    end
  end
end

if Habitat.quart
  Habitat.add_adapter(:diary, Diary::Database.with_adapter.new(Habitat.quart.media_path))  
end



