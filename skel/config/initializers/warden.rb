Warden::Strategies.add(:password) do

  def valid?
    params['username'] || params['password']
  end
  
  def authenticate!
    u = Habitat.adapter(:user).user(params['username']).authenticate(params['password'])
    u.nil? ? fail!("Could not log in") : success!(u)
  rescue
    p $!
    false
  end
end

Warden::Strategies.add(:token) do
  def valid?
    params["token"]
  end
  
  def authenticate!
    tkn = params["token"]
    u = Habitat.adapter(:user).by_token(tkn)
    u.nil? ? fail!("Could not log in") : success!(u)
    false
  rescue
    p $!
    false
  end
end



Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  Habitat.adapter(:user).by_id(id)
end
