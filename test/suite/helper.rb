TMP_PATH = "/tmp/minitest"

class MockUser
  attr_reader :id
  def self.id
    (@id ||= 0)
    @id += 1
  end
  def initialize(name)
    @id = MockUser.id
    @name = name
  end

  def user_path
    id.to.s
  end

  def diary_path(*args)
    File.join(TMP_PATH, "sheets", @id.to_s, *args)
  end
end


module TestMixins
  module UserMixin
    MockUser1 = MockUser.new("deine")
    MockUser2 = MockUser.new("mama")

    def with_user(&blk)
      @adapter.with_user(@user, &blk)
    end
  end
end

