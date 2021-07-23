module SimpleDB

  module Database
    extend Habitat::Database

    class Adapter
      class File < Habitat::Database::Adapter
        def initialize(path)
          @path = path
        end

        def repository_path(*args)
          ::File.join(@path, "db", *args) 
        end

        def [](what)
          SimpleDB.databases[what]
        end
      end
    end
  end
  
end

