module Insta::Controllers::Insta
  class Callback
    include Insta::Action

    def call(params)
      pp params
      pp 1
      pp request
    end
  end
end
