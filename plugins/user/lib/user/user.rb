require_relative "database"

module User

  DEFAULT_ADAPTER = :File

  class User

    include BCrypt
    
    Attributes = {
      :name        => String,
      :email       => String,
      :password    => String,
      :user_id     => String
    }

    attr_reader *Attributes.keys

    OptionalAttributes = []


    def self.filename(usr)
      "%s%s" % [ usr.name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, ''), ::User::Database::Adapter::File::USERFILE_EXTENSION ]
    end

    def initialize
    end

    def id
      user_id
    end

    def ==(obj)
      id == obj
    end

    def populate(param_hash)
      @password = Password.create(param_hash.delete(:password))
      @user_id  = Habitat::Database.get_random_id
      param_hash.each do |paramkey, paramval|
        instance_variable_set("@#{paramkey}", paramval)
      end
      self
    end

    def authenticate(pw)
      Password.new(self.password) == pw and self
    end

    def filename
      User.filename(self)
    end

  end
end

if Habitat.quart
  Habitat.add_adapter(:user, User::Database.with_adapter.new(Habitat.quart.media_path))  
end

