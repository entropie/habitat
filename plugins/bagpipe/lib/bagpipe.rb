require_relative "bagpipe/database"
require_relative "bagpipe/repository"

module Bagpipe

  DEFAULT_ADAPTER = :File

  def expand_path(*strs)
    ::File.expand_path(::File.join(@path, *strs))
  end

  
  def repository
    @repository ||= Repository.new(path)
  end

end
