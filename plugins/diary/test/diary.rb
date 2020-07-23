
require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/diary/diary"

require "minitest/autorun" if __FILE__ == $0

require "fileutils"

include Diary
include TestMixins

Habitat.add_adapter(:diary, Diary::Database.with_adapter.new(TMP_PATH))

def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end

Habitat::Tests::Suites::PluginsTestSuite.environment(:diary) do
  def prepare!
  end
  
  def teardown!
    _clr
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
    @adapter = Habitat.adapter(:diary)
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

class TestFileAdapaterBasicUser < Minitest::Test

  include UserMixin

  def setup
    @user = MockUser1
    @adapter = Habitat.adapter(:diary)
  end

  def test_user_path
    @adapter.with_user(@user) {|a|
      assert_equal a.user, @user
      assert_equal a.user_path, File.join(@adapter.path, "diary/1")
      assert_equal a.current_sheet_path, File.join(@adapter.path, "diary/1/sheets", *Time.now.strftime("%Y/%m/").split("/"))
    }
    assert_nil @adapter.user
  end

  def test_no_sheets
    _clr
    assert_equal with_user{|a| a.sheets }, []
    assert_kind_of Diary::Sheets, with_user{|a| a.sheets }
  end

end

class TestSheets < Minitest::Test

  include UserMixin

  def setup
    @user = MockUser1
    @adapter = Habitat.adapter(:diary)
    @text = "Lorem ipsum dolor sit amet commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt"
  end

  def test_make_sheet
    with_user do |a|
      sheet = a.create(@text)
      assert sheet.valid?
      assert_equal @text, sheet.content
      @adapter.store(sheet)
      assert_equal 1, @adapter.sheets.size
    end

    _clr
  end

end
