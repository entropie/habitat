require_relative "felle/database"
require_relative "felle/images"
require_relative "felle/felle"


if Habitat.quart
  Habitat.add_adapter(:felle, Felle::Database.with_adapter.new(Habitat.quart.media_path))  
end
