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


if Habitat.quart
  if not (bp_root = C["bagpipe_root"]).nil?
    bp_root = ::File.expand_path(bp_root)
    Habitat.add_adapter(:bagpipe, Bagpipe::Database.with_adapter.new( bp_root  ))
  else
    warn "bagpipe module activated but no `bagpipe_root' entry in projectsettings"
    sleep 5
  end
end
