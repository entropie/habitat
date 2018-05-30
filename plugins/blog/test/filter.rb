require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/blog/blog"
require File.dirname(__FILE__) + "/../../flickr/lib/flickr/flickr"


require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:blog, Blog::Database.with_adapter.new(TMP_PATH))

include Blog
include TestMixins



PostHash = {
  :title => "testtitle?",
  :content => MARKDOWN,
  :tags => "foo, bar"
}

def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end


class TestEntriesWithUser < Minitest::Test

  include UserMixin

  def setup
    _clr
    @user = MockUser1
    @adapter = Habitat.adapter(:blog)
  end

  def test_filter
    @adapter.with_user(@user) do |a|
      post = a.create(PostHash)

      post.with_filter
    end
  end
end
