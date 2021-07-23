require_relative "simpledb/database.rb"
require_relative "simpledb/simpledb.rb"


if Habitat.quart
  Habitat.add_adapter(:simpledb, SimpleDB::Database.with_adapter.new(Habitat.quart.media_path))  
end
SimpleDB.read_from(Habitat.adapter(:simpledb))

