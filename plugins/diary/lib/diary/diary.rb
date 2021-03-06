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

      def retval
        @retval ||= {}
      end

      def diary(*args, &blk)
        adapter_with_usercontext(:diary, *args, &blk)
      end
    end
  end

  
  class Diaries < Array
  end
  
end

if Habitat.quart
  Habitat.add_adapter(:diary, Diary::Database.with_adapter.new(Habitat.quart.media_path))  
end



