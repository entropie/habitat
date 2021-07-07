require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/booking"

require "minitest/autorun" if __FILE__ == $0

Habitat.add_adapter(:booking, Booking::Database.with_adapter.new(TMP_PATH))

include TestMixins

def _clr
  FileUtils.rm_rf(TMP_PATH, :verbose => true)
end

def adapter
  Habitat.adapter(:booking).with_user(MockUser)
end

TestEvents = [
  {attender_slots: 10, protagonists: ["foo"], slug: "test", start_date: Time.new(2021, 5, 1, "15:00"), end_date: Time.new(2021, 5, 1, "17:00")},
  {attender_slots: 15, protagonists: ["foo"], slug: "testa", start_date: Time.new(2021, 5, 1, "17:00"), end_date: Time.new(2021, 5, 1, "19:00")},

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
    assert ev.exist?
  end

  def test_event_files
    
    assert_equal File.join(TMP_PATH, "booking", "events", "20"),
     ::Booking::Events.new(self, year: 20, month: nil).directory

    assert_equal File.join(TMP_PATH, "booking", "events", Time.now.strftime("%y"), "05"),
                 ::Booking::Events.new(self, month: 5).directory

    assert_equal File.join(TMP_PATH, "booking", "events", Time.now.strftime("%y"), Time.now.strftime("%m")),
                 ::Booking::Events.new(self).directory

  end

  def test_list_events
    adapter.create(:event, TestEvents[0])
    adapter.create(:event, TestEvents[1])
    adapter.create(:event, TestEvents[2])

    assert_equal 2, adapter.events(year: 21, month: 5).to_a.size
    assert_equal 3, adapter.events(year: 21, month: nil).to_a.size
  end
end
