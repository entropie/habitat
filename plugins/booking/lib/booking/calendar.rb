# coding: utf-8
module Booking
  module Calendar

    class OptHash < Hash
      def [](obj)
        fetch(obj.to_sym)
      rescue
        nil
      end
    end

    def self.process_opts(opts)
      retHash = OptHash.new
      retHash[:year]  = opts[:year].to_i if opts[:year]
      retHash[:month] = opts[:month].to_i if opts[:month]
      retHash[:day] =   opts[:day].to_i if opts[:day]
      retHash[:year]  ||= Date.today.year
      retHash[:month] ||= Date.today.month
      retHash
    end


    # class Timespan
    #   def initialize
    #   end

    #   def date
    #     Date.new(@year.year, @month && month.month, @day && day.day)
    #   end
    # end

    module DEntity
      def days_between(first, second)
        if first > second
          second + (7 - first)
        else
          second - first
        end
      end

      def beginning_of_week(date, start = 1)
        days_to_beg = days_between(start, date.wday)
        date - days_to_beg
      end

      def date
        arr = [year.year, (month.month rescue month), (day.day rescue @day || nil)].flatten.compact
        Date.new(*arr)
      end

      def daynames
        dn = Date::ABBR_DAYNAMES.dup
        s = dn.shift
        [dn, s].flatten
      end


    end
    
    class Year
      include DEntity
      attr_reader :year
      def initialize(year = Date.today.year)
        @year = year
      end
    end

    class Month

      include DEntity

      attr_reader :year, :month

      def initialize(month: Date.today.month, year: Year.new)
        @year = Year.new(year)
        @month = month
      end

      def name
        Date::MONTHNAMES[month]
      end

      def previous
        day(first_day - 1).month
      end

      def next
        day(last_day + 1).month
      end
      
      def url
        File.join(@year.year.to_s, month.to_s)
      end

      def thead
        daynames
      end

      def last_day
        Date.new(year.year, month, -1)
      end

      def first_day
        Date.new(year.year, month, 1)        
      end

      def days
        (first_day .. last_day)
      end

      def day(d)
        return_day = Day.new(year: d.year, month: d.month, day: d.day)
        return_day.actual_month = self
        return_day
      end

      def weeks
        retweeks = {}
        days.each {|d|
          retweeks[d.cweek] ||= []
          retweeks[d.cweek].push(d)
        }

        if retweeks[days.first.cweek].size < 7
          (1).upto(7 - retweeks[days.first.cweek].size) do |i|
            retweeks[days.first.cweek].unshift(days.first - i)
          end
        end

        if retweeks[days.last.cweek].size < 7
          (1).upto(7 - retweeks[days.last.cweek].size) do |i|
            retweeks[days.last.cweek].push(days.last + i)
          end
        end
        retweeks
      end

      def tr_weeks
        ret = []
        weeks.each_pair do |wn, days|
          ret.push( "<tr data-weeknr='%s'>%s</tr>" % [wn, days.map{|d| day(d).to_html }.join])
        end
        ret.join
      end

      def to_html(id = "cal")
        table = %Q(<table class="calendar-table" id="#{id}">%s%s</table>)
        head  = %Q(<thead><tr>%s</tr></thead>) % thead.map{|th| "<th>#{th}</th>" }.join
        body =  %Q(<tbody>%s</tbody>) % tr_weeks
        table % [head, body]
      end

    end

    class Day
      include DEntity
      attr_reader :year, :month, :day
      attr_accessor :actual_month
      def initialize(day: Date.today.day, year: Year.new, month: Month.new)
        @year  = Year.new(year)
        @month = Month.new(month: month, year: @year.year)
        @day   = day
      end

      def today?
        date == Date.today
      end
      
      def css_class
        cls = []
        if date < actual_month.first_day
          cls << "past"
        elsif date > actual_month.last_day
          cls << "future"
        else
          cls << "current"
        end

        cls << "today" if today?
        
        cls.join(" ")
      end

      def to_html
        "<td data-datestr='%s' class='%s'>%s</td>" % [date.strftime("%y-%m-%d"), css_class, date.day]
      end
    end

    extend DEntity

    def self.from_params(params)
      opts = Calendar.process_opts(params)
      r = Month.new(opts)
      r
    end

    def self.to_html(o = {}, &blk)
      opts = Calendar.process_opts(o)
      id = opts.delete(:id)
      a = Day.new(opts)
      a.month.to_html(id)
    end

  end
end


