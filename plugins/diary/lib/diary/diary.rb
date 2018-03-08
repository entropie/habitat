# coding: utf-8
#
#

require 'digest/sha1'
require 'securerandom'
require 'yaml'

require_relative "database"
require_relative "sheets"
require_relative "snippets"


module Diary

  DEFAULT_ADAPTER = :File
  
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


class User
  def diary_path(*args)
    Habitat.quart.media_path("diaries", *args)
  end
end
