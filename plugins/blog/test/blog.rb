require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/blog/blog"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:blog, Blog::Database.with_adapter.new(TMP_PATH))

include Blog
include TestMixins

Habitat::Tests::Suites::PluginsTestSuite.environment(:blog) do
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
  :title => "testtitle?",
  :content => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do",
  :tags => "foo, bar"
}


class TestReadpi < Minitest::Test
  def setup
    @adapter = Habitat.adapter(:blog)
  end

  def test_read_api
    api = Blog::ReadAPI.new("https://fluffology.de/api/post")
    ret = api.posts
    p ret.first["url"]
  end
end

class TestDatabase < Minitest::Test
  def test_default_adapter
    assert_equal Database.adapter, :File
  end

  def test_default_adapter_db_instance
    assert_equal Database.with_adapter, Database::Adapter::File
  end

  def test_should_be_possible_to_create_an_instance
    assert_raises {
      Database.with_adapter.new
    }
    assert Database.with_adapter.new("test")
  end

end

class TestFileAdapater < Minitest::Test
  def setup
    @adapter = Habitat.adapter(:blog)
  end

  def test_adapter_should_respond_to_path
    assert @adapter.path, TMP_PATH
  end

  def test_setup
    assert @adapter.setup
  end

  def test_query
    assert_raises{ @adapter.query }
  end

  def test_sheets
    assert_raises { @adapter.sheets }
  end

end

class TestEntries < Minitest::Test
  def setup
    _clr
    @adapter = Habitat.adapter(:blog)
  end

  def test_adapter_repository_path
    assert @adapter.repository_path, File.join(TMP_PATH, "blog")
  end

  def test_setup
    assert @adapter.setup
  end

  def test_query
    assert_raises{ @adapter.query }
  end

  def test_sheets
    assert_raises { @adapter.sheets }
  end

  def test_entries
    assert_equal [], @adapter.posts
  end

end


class TestEntriesWithUser < Minitest::Test

  include UserMixin
  
  def setup
    _clr
    @user = MockUser1
    @adapter = Habitat.adapter(:blog)
  end

  def test_entries
    @adapter.with_user(@user) do |a|
      assert_equal [], a.posts
      assert_equal @user, a.posts.user
    end
  end
end

class TestCreatePost < Minitest::Test

  include UserMixin
  
  def setup
    @user = MockUser1
    @adapter = Habitat.adapter(:blog)
  end

  def test_create_wo_user
    assert_raises { @adapter.create("foo") }
  end

  def test_create_with_user
    post = @adapter.with_user(@user) do |a|
      a.create(PostHash)
    end
    assert_equal "testtitle", post.slug
    assert_equal PostHash[:title], post.title
    assert_equal PostHash[:content], post.content
    assert_equal "/tmp/minitest/data/testtitle", post.datadir
    assert_equal "/tmp/minitest/blog/drafts/testtitle.post.yaml", post.filename

    @adapter.with_user(@user) do |a|
      a.store(post)
    end

    @adapter.with_user(@user) {|a|
      assert_equal 1, a.posts.size
      assert_equal post.title, a.posts.first.title
      #p a.posts.first.to_post(a)
      a.to_post(a.posts.first)
      a.to_draft(a.posts.first)
      #a.destroy(a.posts.first)
    }

    
  end

end




class TestCreatePost < Minitest::Test

  include UserMixin
  
  def setup
    @user = MockUser1
    @adapter = Habitat.adapter(:blog)
    @template_path = File.join(File.dirname(__FILE__), "templates")
  end

  def test_create_wo_user
    assert_raises { @adapter.create("foo") }
  end

  def test_create_with_user
    # post = @adapter.with_user(@user) do |a|
    #   a.create(PostHash)
    # end
    
    # post = @adapter.with_user(@user) do |a|
    #   i = File.open( File.join(File.dirname(__FILE__), "test.jpg"))
    #   post = a.create(PostHash)
    #   a.upload(post, i)
    #   post
    # end

    # @adapter.with_user(@user) do |a|
    #   a.store(post)
    # end

    # assert post.image.path
    # t =  Blog.templates(@template_path)[:alpha].apply(post)
    # puts t.javascript
    # puts t.styles
    # p t.ruby
    # p t.template
    # p t.compile
    # p post.with_template(:prettyok).compile

  end

end

