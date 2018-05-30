require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/flickr/flickr"

require "minitest/autorun" if __FILE__ == $0

def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end


class TestFlickr < Minitest::Test

  include Flickr
  
  def setup
    FileUtils.mkdir_p(File.join(TMP_PATH, "flickr"))
  end

  def test_filter
    p FI(33611513224)

  end
end
