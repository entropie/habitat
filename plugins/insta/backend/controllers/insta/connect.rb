# CALLBACK_URL = "https://localhost:2308/_insta/callback"
CALLBACK_URL = "http://konstanze-pietschmann.com/_insta/callback"
require "instagram"

module Insta::Controllers::Insta
  class Connect
    include Insta::Action

    def call(params)
      a = ::Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
      b = a+"&scope=user_media&response_type=code"
      p b
      redirect_to b

    end
  end
end
