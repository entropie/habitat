require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/spoolnotif/spoolnotif"

require "minitest/autorun" if __FILE__ == $0

# Habitat.add_adapter(:blog, Blog::Database.with_adapter.new(TMP_PATH))

# include Blog
include TestMixins

Habitat::Tests::Suites::PluginsTestSuite.environment(:spoolnotif) do
  def prepare!
  end
  
  def teardown!
    #_clr
  end
end

def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end


class TestReadpi < Minitest::Test
  # def setup
  #   @adapter = Habitat.adapter(:blog)
  # end

  def test_a
    Spoolnotif << ["foo", self.class]
    Spoolnotif << ["bar", self.class]
    Spoolnotif << ["bum", self.class]
    Spoolnotif << ["hallo welt", self.class]

    pp Spoolnotif.spooler
  end
  
  # def test_read_api
  #   api = Blog::ReadAPI.new("https://fluffology.de/api/post")
  #   ret = api.posts
  #   # sleep 3
  #   ret = api.posts
  #   # p ret.first.class
  #   # ret = api.posts
  #   # ret = api.posts
  #   # p ret.first["url"]
  # end
end

