module User
  module Database
    extend Habitat::Database

    class Adapter
      class File < Habitat::Database::Adapter

        USERFILE_EXTENSION = ".user.yaml".freeze

        include Habitat::Mixins::FU

        def initialize(path)
          @path = path
        end

        def path(*args)
          ::File.join(@path, *args)
        end

        def adapter_class
          User
        end

        def repository_path(*args)
          ::File.join(::File.realpath(path), "user", *args)
        rescue Errno::ENOENT
          warn "does not exist: #{path("user")}"
          path("user", *args)
        end
        
        def setup
          @setup = true
          log :debug, "setting up adapter directory #{path}"
          FileUtils.mkdir_p(path)
          @setup
        end

        def user_files
          Dir.glob(repository_path + "/*" + USERFILE_EXTENSION)
        end

        def user(username = nil)
          if username
            fn = User.filename(username)
            
            return YAML::load_file(repository_path(fn))
          end
          user_files.map{|uf| YAML::load_file(uf) }
        end

        def by_id(id)
          user.select{|u| u == id }.first
        end

        def by_token(token)
          decoded = JWT.decode(token, Habitat.quart.secret, true, { algorithm: 'HS256' })
          e = decoded.first
          usr = by_id(e["user_id"])
          if usr.password.to_s == e["password"]
            return usr
          else
            return nil
          end
        rescue JWT::VerificationError
          return nil
        end

        def create(param_hash)
          store( User.new.populate(param_hash) )
        end

        def store(usr)
          filename = repository_path(usr.filename)
          mkdir_p(dirname(filename))
          log :info, "storing user:#{usr.name}"
          write(filename, YAML::dump(usr))
        end
      end
    end
  end
end
