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
      us = usr.kind_of?(User) ? usr.name : usr
      "%s%s" % [ us.strip.gsub(' ', '-').gsub(/[^\w-]/, ''), ::User::Database::Adapter::File::USERFILE_EXTENSION ]
    end

    def initialize
    end

    def id
      user_id
    end

    def ==(obj)
      id == obj
    end

    def token
      token = JWT.encode({:password => password, :user_id => id}, Habitat.quart.secret, 'HS256')
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

    def to_s
      '[%s  %s <%s> "%s"]' % [id, name, email, token]
    end

  end
end

if Habitat.quart
  Habitat.add_adapter(:user, User::Database.with_adapter.new(Habitat.quart.media_path))  

  #p Habitat.adapter(:user).create(:name => "entropie", :password => "lala", :email => "mictro@gmail.com")
end



