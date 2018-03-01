require 'roar/decorator'
require 'roar/json'

module Api::Representers
  class Posts < Roar::Decorator
    include Roar::JSON

    collection :posts
  end
end
