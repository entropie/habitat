require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/stars"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:stars, Stars::Database.with_adapter.new(TMP_PATH))


def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end

def adapter
  Habitat.adapter(:stars)
end

def img
  File.expand_path("~/Downloads/void.jpg")
end

def create_michis
  adapter.create("michi trommer", 5, "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", img)
end


class TestStars < Minitest::Test

  include Stars
  
  def setup
    _clr
    FileUtils.mkdir_p(File.join(TMP_PATH, "stars"))
  end

  def test_michis
    create_michis
  end

  def test_michis_existing
    create_michis
    assert_raises ::Stars::StarAlreadyExist do
      create_michis
    end
  end

  def test_stars
    create_michis
    assert_equal adapter.stars.size, 1
  end

  def test_get_michis
    create_michis
    assert_equal adapter.stars["michi trommer"].ident, "michi-trommer"
  end

  def test_remove_michis
    create_michis
    adapter.stars["michi trommer"].destroy
    assert_equal adapter.stars.size, 0
  end


  def test_update_or_create_new
    hsh = {
      :ident => "michi trommer",
      :stars => "5",
      :content => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      :image => img}
    adapter.update_or_create(hsh)
    assert_equal adapter.stars["michi trommer"].ident, "michi-trommer"
  end

  def test_update_or_create_existing
    hsh = {
      :ident => "michi trommer",
      :stars => "5",
      :content => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      :image => img}
    adapter.update_or_create(hsh)
    assert_equal adapter.stars["michi trommer"].ident, "michi-trommer"


    hsh = {
      :ident => "michi trommer", 
      :stars => "3",
      :content => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      :image => img}
    adapter.update_or_create(hsh)
    assert_equal adapter.stars["michi trommer"].stars, 3
  end


end
