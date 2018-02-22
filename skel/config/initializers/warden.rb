Warden::Strategies.add(:password) do

  def valid?
    params['username'] || params['password']
  end

  def authenticate!
    u = User.authenticate(params['username'], params['password'])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  Users[id]
end


class Users
  def self.db
    @db ||= Array.new
  end

  def self.add(u, p)
    usr = User.new(u)
    Users.db << usr
    usr
  end

  def self.[](o)
    Users.db.select{|u| u.id == o}.first rescue nil
  end
end

class User

  include BCrypt

  attr_accessor :password_hash, :name

  def id
    1
  end
  
  def initialize(name)
    @name = name
  end
  
  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def self.authenticate(username, password)
    user = Users[1]
    if !user.nil? && user.password == password
      Habitat.log :info, "user authenticated"
      return user
    end
    nil
  end

end


Users.add("entropie", "lala").password = "lala"

