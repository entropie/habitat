require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/felle"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:felle, Felle::Database.with_adapter.new(TMP_PATH))


# def _clr
#   FileUtils.rm_rf(TMP_PATH, :verbose => true)
# end

def adapter
  Habitat.adapter(:felle)
end

class TestFell < Minitest::Test

  include Felle
  
  def setup
    #FileUtils.mkdir_p(File.join(TMP_PATH, "snippets"))
  end

  def test_filter
    timg = "/home/mit/2018-11-11-015643_779x766_scrot.png"
    #p adapter.create(:foo, "deine **mama** ist ein schaf")
    #p adapter.create(:foo, "deine **mama** ist ein schaf", :haml)
    #puts adapter[:foo].render

    # a = adapter.create("bort",
    #                    attributes: { :neutered => 1},
    #                    birthday: Time.new(2007, 5, 1),
    #                    breed: "Magyar Vizsla",
    #                    origin: "Hungary",
    #                    gender: 0,
    #                    state: 0)
    # # pp a.root
    # # pp a.http_path
    # # pp a.http_datadir
    # # a.birthday = 1
    # # a.breed = "b"
    # # a.origin = "lala"
    # # a.gender = 1
    # if a.valid?
    #   adapter.store(a)
    # end

    a = adapter.find("bort")

    # i = Felle::Fell::Image.new(timg)
    # p i.copy_to(a)
    p a.images.first.url
    # p a.gender_human
    #adapter.store(a)
  end
end
