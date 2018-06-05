require_relative "snippets/database"
require_relative "snippets/snippets"


if Habitat.quart
  Habitat.add_adapter(:snippets, Snippets::Database.with_adapter.new(Habitat.quart.media_path))  
end
