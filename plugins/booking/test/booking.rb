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
  {title: "foobar", attender_slots: 10, protagonists: ["foo"], slug: "test", start_date: Time.new(2021, 5, 1, "15:00"), end_date: Time.new(2021, 5, 1, "17:00")},
  {title: "barfoo", attender_slots: 15, protagonists: ["foo"], slug: "testa", start_date: Time.new(2021, 5, 1, "17:00"), end_date: Time.new(2021, 5, 1, "19:00")},
  {title: "batz", attender_slots: 20, protagonists: ["foo"], slug: "test-two", start_date: Time.new(2021, 6, 1, "15:00"), end_date: Time.new(2021, 6, 2, "17:00")},
  {title: "batzbumm", attender_slots: 20, protagonists: ["foo"], slug: "test-two", start_date: Time.new(2023, 6, 1, "15:00"), end_date: Time.new(2023, 6, 2, "17:00")}
]

TestReccuringEvents = [
  {
    :title=>"title1",
    :ident=>"foobar",
    :type=>"testb",
    :start_date=>"2021/07/16 20:00",
    :dates=>
    {
      :begin=>
      ["2021/07/16 20:00",
       "2021/07/17 20:00",
       "2021/07/18 20:00",
       "2021/07/19 20:00",
       "2021/07/20 20:00"],
      "end"=>
      ["2021/07/16 22:00",
       "2021/07/17 22:00",
       "2021/07/18 22:00",
       "2021/07/19 22:00",
       "2021/07/20 22:00"]
    },
    :end_date=>"2021/07/20 22:00",
    :attender_slots=>"3",
    :protagonists=>["foobar"],
    :content=>"fofoofof",
    :slug=>"foobar"}
]

class Booking::Events::TestA < Booking::Events::Event
  def human_type
    "testa"
  end
end


class Booking::Events::TestB < Booking::Events::Recurrent
  def human_type
    "testb"
  end
end







class TestEventPath < Minitest::Test

  include Booking
  
  def setup
    _clr
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


class TestSlots < Minitest::Test

  include Booking
  def setup
    _clr
    FileUtils.mkdir_p(File.join(TMP_PATH, "booking"))
  end

  def wd(a = 2021, b = 7, c = 8)
    Booking::Workday.read_or_new(a, b, c)
  end

  def test_slot_path
    day = wd
    entry = day.fill(Booking::Workday::Single, 14)
    entry.merge(phone: "1123", name: "Deine Mutter")

    adapter.store(day)

    day = wd
    assert day.exist?
    assert "Deine Mutter", day.slots[14].name
  end

  def test_slot_available
    assert wd.slots.first.available?
    assert wd.slots[14].available?
  end
  
  def test_slot_fill
    day = wd
    
    entry = day.fill(Booking::Workday::Single, 14)
    entry.merge(phone: "1123", name: "Deine Mutter")

    entry = day.fill(Booking::Workday::Single, 16)
    entry.merge(phone: "1123", name: "Dein Vater")

    day.fill(Booking::Workday::Blocked, 12)

    assert_equal false, day.slots[14].available?
    assert_equal false, day.slots[16].available?
    assert_equal false, day.slots[12].available?
    
  end


end

class TestGet < Minitest::Test

  include Booking
  def setup
    _clr
    FileUtils.mkdir_p(File.join(TMP_PATH, "booking"))
  end

  def test_get_all
    adapter.create(:event, TestEvents[0])
    adapter.create(:event, TestEvents[1])
    adapter.create(:event, TestEvents[2])
    adapter.create(:event, TestEvents[3])
    assert_equal 4, adapter.events_all.size
  end


end


class TestUpdate < Minitest::Test

  include Booking
  def setup
    _clr
    FileUtils.mkdir_p(File.join(TMP_PATH, "booking"))
  end

  def test_get_all
    adapter.create(:event, TestEvents[0])
    ev = adapter.events_all.first
    adapter.update(ev, title: "barbum")
    assert_equal "barbum", adapter.events_all.first.title
  end
end


class TestTypes < Minitest::Test

  include Booking
  def setup
    _clr
    FileUtils.mkdir_p(File.join(TMP_PATH, "booking"))
  end

  def test_get_all
    adapter.create(:event, TestEvents[0].merge(type: :testa ))
    assert_equal 1, adapter.events_all.size
    
    assert_equal Booking::Events::TestA, adapter.events_all.first.class
    assert_kind_of Booking::Events::Event, adapter.events_all.first
  end
end



class TestTypes1000 < Minitest::Test

  include Booking
  def setup
    _clr
    FileUtils.mkdir_p(File.join(TMP_PATH, "booking"))
  end

  def test_get_all
    te = TestEvents[0].merge(type: :testa )
    adapter.create(:event, te)

    event = adapter.events_all.first
    adapter.update( event, type: :event)
    assert_equal :event, adapter.events_all.first.type
  end

  def test_find_update_or_create
    assert_equal :event, adapter.find_update_or_create(TestEvents[0]).type
    assert_equal 1, event = adapter.events_all.size
  end


end


class TestReccuringDates < Minitest::Test

  include Booking
  def setup
    _clr
    FileUtils.mkdir_p(File.join(TMP_PATH, "booking"))
  end

  def test_get_all
    te = TestReccuringEvents[0]
    adapter.create(:event, te)

    se = adapter.events_all.first
    assert_equal 5, se.dates.size
  end


end
