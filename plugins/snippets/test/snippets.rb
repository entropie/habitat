require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/snippets"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:snippets, Snippets::Database.with_adapter.new(TMP_PATH))


def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end

def adapter
  Habitat.adapter(:snippets)
end

class TestFlickr < Minitest::Test

  include Snippets
  
  def setup
    FileUtils.mkdir_p(File.join(TMP_PATH, "snippets"))
  end

  def test_filter
    #p adapter.create(:foo, "deine **mama** ist ein schaf")
    #p adapter.create(:foo, "deine **mama** ist ein schaf", :haml)
    puts adapter[:foo].render
  end
end
