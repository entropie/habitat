require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/tumblog/tumblog"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:tumblog, Tumblog::Database.with_adapter.new(TMP_PATH))

include Tumblog
include TestMixins

Habitat::Tests::Suites::PluginsTestSuite.environment(:tumblog) do
  def prepare!
  end
  
  def teardown!
    #_clr
  end
end

def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end

PostHash = {
  :content => "http//i.imgur.com/74tQpTa.gif",
  :tags => "comic, meme"
}


# class TestCreatePost < Minitest::Test

#   include UserMixin
  
#   def setup
#     @user = MockUser1
#     @adapter = Habitat.adapter(:blog)
#   end

#   def test_create_wo_user
#     assert_raises { @adapter.create("foo") }
#   end

#   def test_create_with_user
#     post = @adapter.with_user(@user) do |a|
#       a.create(PostHash)
#     end
#     assert_equal "testtitle", post.slug
#     assert_equal PostHash[:title], post.title
#     assert_equal PostHash[:content], post.content
#     assert_equal "/tmp/minitest/data/testtitle", post.datadir
#     assert_equal "/tmp/minitest/blog/drafts/testtitle.post.yaml", post.filename

#     @adapter.with_user(@user) do |a|
#       a.store(post)
#     end

#     @adapter.with_user(@user) {|a|
#       assert_equal 1, a.posts.size
#       assert_equal post.title, a.posts.first.title
#       #p a.posts.first.to_post(a)
#       a.to_post(a.posts.first)
#       a.to_draft(a.posts.first)
#       #a.destroy(a.posts.first)
#     }

    
#   end

# end




class TestCreatePost < Minitest::Test

  include UserMixin
  
  def setup
    @user = MockUser1
    @adapter = Habitat.adapter(:tumblog)
    @template_path = File.join(File.dirname(__FILE__), "templates")
  end

  def test_create_wo_user
    assert_raises { @adapter.create("foo") }
  end

  def test_create_with_user

    0.upto(10) do
      post = @adapter.with_user(@user) do |a|
        post = a.create(PostHash)
        post
      end
      @adapter.with_user(@user) do |a|
        a.store(post)
      end
    end
    p @adapter.entries.first

  end

end

