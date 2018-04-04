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

