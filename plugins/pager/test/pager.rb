require File.dirname(__FILE__) + "/../../../lib/habitat"
require File.dirname(__FILE__) + "/../../../test/test"

require File.dirname(__FILE__) + "/../lib/pager"

require "minitest/autorun" if __FILE__ == $0


MoreThan10 = (0..25).to_a


class TestPages < Minitest::Test
  def setup
    @pager = Pager::PagerNew.new({  }, MoreThan10, 5)
  end

  # def test_page1
  #   pager = Pager::PagerNew.new({ page: 1 }, MoreThan10, 5)
  #   pager.to_html
  # end

  # def test_page2
  #   pager = Pager::PagerNew.new({ page: 25 }, MoreThan10, 5)
  #   pager.to_html
  # end


  def test_page1
    pager = Pager::PagerNew.new({ page: 1 }, MoreThan10, 3)
    pager.link_proc = -> (n) { "/a/b/#{n}" }

    cur = pager.collect

    #assert_equal cur.first.class,
    assert_equal cur[0].class, Pager::PagerNew::PagerNavigationItem
    assert_equal cur[1].class, Pager::PagerNew::PagerNavigationItem

    assert cur[0].disabled?

    assert_equal cur[2].class, Pager::PagerNew::PagerItem
    assert_equal cur[3].class, Pager::PagerNew::PagerItem    
    assert_equal cur[5].class, Pager::PagerNew::PagerSpacer

    assert_equal cur[7].class, Pager::PagerNew::PagerNavigationItem    
    assert_equal cur[-2].class, Pager::PagerNew::PagerNavigationItem    
    assert_equal cur[-1].class, Pager::PagerNew::PagerNavigationItem

    assert_equal false, cur[-1].disabled?
    
    # pager.collect.each do |pi|
    #   p pi
    # end
    
  end

  
end
