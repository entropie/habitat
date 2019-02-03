require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/galleries"

require "minitest/autorun" if __FILE__ == $0

include Galleries

Habitat.add_adapter(:galleries, Galleries::Database.with_adapter.new(TMP_PATH))

Adapter = Habitat.adapter(:galleries)

TestImageDir = File.join(File.dirname(__FILE__), "test_images")
TestImages   = Dir.glob("#{TestImageDir}/*.*").sort

Habitat::Tests::Suites::PluginsTestSuite.environment(:galleries) do
  def prepare!
    FileUtils.mkdir_p(TMP_PATH, :verbose => true)
  end
  
  def teardown!
    p 1
  end
end


class CreateGallery < Minitest::Test
  # def test_default_adapter
  #   assert_equal Database.adapter, :File
  # end

  # def test_default_adapter_db_instance
  #   assert_equal Database.with_adapter, Database::Adapter::File
  # end

  # def test_should_be_possible_to_create_an_instance
  #   assert_raises {
  #     Database.with_adapter.new
  #   }
  #   assert Database.with_adapter.new("test")
  # end

  def test_create_gallery
    puts
    g = Adapter.find_or_create("foobar")
    # g = Galleries::Gallery.new("foobar")
    #pp g.metadata

#Adapter.transaction(g) do |gal|
    #g.add(TestImages)
    # end
    # Adapter.transaction(g) do |gal|
    #   gal.add(TestImages)
    # end
    pp g.metadata.images
    
    # p g.images
  end
end
