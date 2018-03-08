require_relative "../../../lib/habitat.rb"

require_relative "diary/diary.rb"

require "minitest/autorun"
require "fileutils"

include Diary


TMP_PATH = "/tmp/minitest"
CLR = proc { FileUtils.rm_rf(TMP_PATH) }
Minitest.after_run { CLR.call }
class MockUser
  attr_reader :id
  def self.id
    (@id ||= 0)
    @id += 1
  end
  def initialize(name)
    @id = MockUser.id
    @name = name
  end

  def user_path
    id.to.s
  end

  def diary_path(*args)
    File.join(TMP_PATH, "sheets", @id.to_s, *args)
  end
end

MockUser1 = MockUser.new("deine")
MockUser2 = MockUser.new("mama")

module TestMixin
  def with_user(&blk)
    @adapter.with_user(@user, &blk)
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
    CLR.call
    @adapter = Database.with_adapter.new("/tmp/minitest")
  end

  def test_adapter_should_respond_to_path
    assert @adapter.path
  end

  def test_should_not_be_setup
    assert_nil @adapter.setup?
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

  def after_test
    p 1
    p 2
    
  end

end

class TestFileAdapaterBasicUser < Minitest::Test
  include TestMixin

  def setup
    @adapter = Database.with_adapter.new("/tmp/minitest")
    @user = MockUser1
  end


  def test_user_path
    @adapter.with_user(@user) {|a|
      assert_equal a.user, @user
      assert_equal a.user_path, File.join(@adapter.path, "sheets/1/sheets")
      assert_equal a.current_sheet_path, File.join(@adapter.path, "sheets/1/sheets", *Time.now.strftime("%Y/%m/").split("/"))
    }
    assert_nil @adapter.user
  end

  def test_no_sheets
    assert_equal with_user{|a| a.sheets }, []
    assert_kind_of Diary::Sheets, with_user{|a| a.sheets }
  end

end

class TestSheets < Minitest::Test

  include TestMixin

  def setup
    @adapter = Database.with_adapter.new("/tmp/minitest")
    @user = MockUser1

    @text1 = "Lorem ipsum dolor sit amet commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt"
  end

  def test_make_sheet
    with_user do |a|
      sheet = a.create_sheet(@text1)
      assert sheet.valid?
      assert_equal @text1, sheet.content
      @adapter.store(sheet)
    end
  end

  def test_read_sheet
    with_user do |a|
      assert_kind_of Diary::Sheets, @adapter.sheets
      assert_equal @text1, @adapter.sheets.first.content
    end
  end


end
