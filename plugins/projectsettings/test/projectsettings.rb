require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/projectsettings/projectsettings"


require "minitest/autorun" if __FILE__ == $0

class TestConfig < Minitest::Test

  def test_a
    C[:foo] = 23


    p C[:foo]
    p C.write
  end

end
