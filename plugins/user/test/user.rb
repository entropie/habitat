require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/user/user"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:user, User::Database.with_adapter.new(TMP_PATH))

include User
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
    @adapter = Habitat.adapter(:user)
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


class TestUserCreate < Minitest::Test
  def setup
    @adapter = Habitat.adapter(:user)
  end

  def test_sheets
    usr = @adapter.create(:name => "test", :email => "test@testor.com", :password => "test")
    assert @adapter.user("test").authenticate("test")
  end

end


class TestUserCreateGroup < Minitest::Test
  def setup
    @adapter = Habitat.adapter(:user)
  end

  def test_group_list
    group_classes = User::Groups.groups
    assert_includes(group_classes, User::Groups::DefaultGroup)
    assert_includes(group_classes, User::Groups::AdminGroup)
  end
  
  def test_default_group
    usr = @adapter.create(:name => "grouptest-def", :email => "test@testor.com", :password => "test")
    assert_includes(usr.groups, User::Groups::DefaultGroup)
  end

  def test_admin_group
    usr = @adapter.create(:name => "grouptest-admin", :email => "test@testor.com", :password => "test")

    usr.add_to_group(User::Groups::AdminGroup)
    @adapter.store(usr)

    assert_includes(usr.groups, User::Groups::AdminGroup)
    assert_includes(usr.groups, User::Groups::DefaultGroup)
  end

end
