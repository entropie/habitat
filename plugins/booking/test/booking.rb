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

TestEvents = [
  {attender_slots: 10, protagonists: ["foo"], slug: "test", start_date: Time.new(2021, 5, 1, "15:00"), end_date: Time.new(2021, 5, 1, "17:00")},
  {attender_slots: 20, protagonists: ["foo"], slug: "test-two", start_date: Time.new(2021, 6, 1, "15:00"), end_date: Time.new(2021, 6, 2, "17:00")}
]

class TestEventPath < Minitest::Test

  include Booking
  
  def setup
    FileUtils.mkdir_p(File.join(TMP_PATH, "booking"))
  end

  def test_event_files_load
    assert_empty adapter.events(year: Time.now.year)
  end

  def test_create_event
    ev = adapter.create(:event, TestEvents.first)
    p ev
  end

  def test_event_files
    
    assert_equal File.join(TMP_PATH, "booking", "events", "20"),
     ::Booking::Events.new(self, year: 20, day: nil, month: nil).directory

    assert_equal File.join(TMP_PATH, "booking", "events", Time.now.strftime("%y"), "5"),
                 ::Booking::Events.new(self, month: 5, day: nil).directory

    assert_equal File.join(TMP_PATH, "booking", "events", Time.now.strftime("%y"), Time.now.strftime("%m"), "23"),
                 ::Booking::Events.new(self, day: 23).directory

    assert_equal File.join(TMP_PATH, "booking", "events", Time.now.strftime("%y"), Time.now.strftime("%m"), Time.now.strftime("%d")),
                 ::Booking::Events.new(self).directory
  end
end
