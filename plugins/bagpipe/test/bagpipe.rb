require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/bagpipe"

require "minitest/autorun" if __FILE__ == $0

BAGPIPE_PATH = ::File.expand_path("~/MInc")

Habitat.add_adapter(:bagpipe, Bagpipe::Database.with_adapter.new(BAGPIPE_PATH))



class TestRepos < Minitest::Test
  def setup

    @adapter = Habitat.adapter(:bagpipe)
  end

  def test_read_api
    # r = @adapter.read("/")
    # pp r
    # r = @adapter.read("/")
    # pp r

    r = @adapter.read("/prod")
    pp r

    # r = @adapter.read("Kanye West - My Beautiful Dark Twisted Fantasy - 320kbps")
    # pp r

    # r = @adapter.read("prod").read("/foo")
    # pp r


    # r = @adapter.read("Dysnomia - Dawn of Midi.mp3")
    # pp r
    # r = @adapter.read("/")
    # pp r.read("prod") #.read("/foo")
    # pp r
    # pp r.read("prod")
    # pp @adapter.read("prod", "..")
  end
end

