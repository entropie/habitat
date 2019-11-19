require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/booking"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:booking, Booking::Database.with_adapter.new(TMP_PATH))


def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end

def adapter
  Habitat.adapter(:booking)
end

class TestFlickr < Minitest::Test

  include Booking
  
  def setup
    FileUtils.mkdir_p(File.join(TMP_PATH, "snippets"))
  end

  def test_filter
    p adapter
  end
end
