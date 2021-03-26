require_relative "database"

module User

  DEFAULT_ADAPTER = :File

  module UserControllerMethods
    def reject_unless_authenticated
      logging_in = ["login", "logout"].include?(params.env["REQUEST_PATH"].split("/").last)

      if logged_in?
        if session_user.is_grouped? and not session_user.part_of?(:admin)
          redirect_to "/"
          exit 23
        end

      elsif logging_in
      else
        halt 404
        exit 23
      end
    end

    def check_token
      if ::Warden::Strategies[:token]
        a = params.env["warden"].authenticate(:token)
        if a and params[:goto]
          redirect_to params[:goto]
        end
      end
    end

  end

  class Groups < Array

    def self.groups
      @groups ||= []
    end

    def self.to_group_cls(str)
      cs = str.to_s.capitalize
      if str.kind_of?(String) and str.include?("::")
        TOPLEVEL.const_get(cs)
      else
        Groups.const_get(cs)
      end
    end

    def =~(grpls)
      grpconst = Groups.to_group_cls(grpls)
      include?( grpconst  ) and grpconst
    end

    def self.to_a
      @groups
    end


    class UserGroup
      def self.inherited(cls)
        Groups.groups.push(cls)
      end

      def self.to_s
        name.to_s.split("::").last.downcase
      end
    end

    class Default < UserGroup
    end

    class Admin < UserGroup
    end

    def initialize(grps = [])
      push(*grps)
    end

  end
  
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


    def add_to_group(grpcls)
      groups.push(grpcls)
    end

    def groups
      @groups ||= Groups.new(Groups::Default)
    end

    def is_grouped?
      instance_variable_get("@groups")
    end

    def part_of?(grp)
      grp = Groups.const_get(grp.to_s.capitalize) if grp.kind_of?(String) or grp.kind_of?(Symbol)
      
      is_grouped? and groups =~ grp
    end

    def id
      user_id
    end

    def ==(obj)
      id == obj
    end

    def token
      token = JWT.encode({ :password => password, :user_id => id }, Habitat.quart.secret, 'HS256')
    end

    def populate(param_hash)
      @password = Password.create(param_hash.delete(:password)) if param_hash[:password]
      @user_id  = Habitat::Database.get_random_id unless param_hash[:user_id]

      groups = param_hash.delete(:groups)

      if groups
        groups_to_write = Groups.new
        groups.each_pair {|gn, gv|
          groups_to_write.push(Groups.to_group_cls(gn))
        }
        param_hash[:groups] = groups_to_write
      end

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
end



