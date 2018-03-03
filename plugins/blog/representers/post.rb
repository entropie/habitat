require 'roar/decorator'
require 'roar/json'

module Api::Representers
  class Post < Roar::Decorator
    include Roar::JSON
    property :title
    property :author
    property :tags
    property :pid
    property :slug
    property :image
    property :date
  end

  class FullPost < Post
    property :content
  end
end
