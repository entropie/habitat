# coding: utf-8
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
module PrettyDate
  

  [ :MONTHNAMES, :DAYNAMES, :ABBR_MONTHNAMES, :ABBR_DAYNAMES ].each do |const|
    Date.send(:remove_const, const)
    Time.send(:remove_const, const) rescue nil
  end

  Date::MONTHNAMES = [nil] + %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember)
  Date::DAYNAMES = %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag)
  Date::ABBR_MONTHNAMES = [nil] + %w(Jan Feb März Apr Mai Jun Jul Aug Sep Okt Nov Dez)
  Date::ABBR_DAYNAMES = %w(So Mo Di Mi Do Fr Sa)
  Time::MONTHNAMES = Date::MONTHNAMES
  Time::DAYNAMES = Date::DAYNAMES
  Time::ABBR_MONTHNAMES = Date::ABBR_MONTHNAMES
  Time::ABBR_DAYNAMES = Date::ABBR_DAYNAMES


  module HumanTime
    def to_human(what = :def)
      fmtstr =
        case what
        when :def
          "%A, %e %B %Y"
        when :int
          "%c"
        end
      mstrftime(fmtstr)
    end

    def only_human_time
      strftime("%H:%M")
    end

    def only_human_date
      to_human
    end

    def to_human_time(sep = " &mdash; ")
      to_human + sep + only_human_time
    end

    def mstrftime(format)
      format = format.dup
      format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
      format.gsub!(/%A/, Date::DAYNAMES[self.wday])
      format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
      format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
      strftime(format)
    end

    def monthname
      Date::MONTHNAMES[self.mon]
    end

    def smonthname
      Date::ABBR_MONTHNAMES[self.mon]
    end

    def dayname
      Date::DAYNAMES[self.wday]
    end

    def sdayname
      Date::ABBR_DAYNAMES[self.wday]
    end

    def form_date
      format_string = "%Y/%m/%d %H:%M"
      strftime(format_string)
    end

    def relative_date(to_or_from_date)
      relative_time(to_or_from_date.to_datetime, :DAYS)
    end

    TIME_UNIT_TO_SECS = { SECONDS:1, MINUTES:60, HOURS:3600, DAYS:24*3600,
                          WEEKS: 7*24*3600 }
    TIME_UNIT_LBLS    = { SECONDS:"Sekunden",
                          MINUTES:"Minuten",
                          HOURS:"Stunden",
                          DAYS:"Tagen",
                          WEEKS: "Wochen",
                          MONTHS:"Monaten",
                          YEARS: "Jahren"
                        }

    def relative_time(date_time, time_unit)
      now = DateTime.now
      if date_time < now
        v = case time_unit
            when :SECONDS, :MINUTES, :HOURS, :DAYS, :WEEKS
              (now.to_time.to_i-date_time.to_time.to_i)/
                TIME_UNIT_TO_SECS[time_unit]
            when :MONTHS
              0.step.find { |n| (date_time >> n) > now } -1
            when :YEARS
              0.step.find { |n| (date_time >> 12*n) > now } -1
            else
              raise ArgumentError, "Invalid value for 'time_unit'"
            end
        "#{v} #{TIME_UNIT_LBLS[time_unit]} ago"
      else
        v = case time_unit
            when :SECONDS, :MINUTES, :HOURS, :DAYS, :WEEKS
              ((date_time.to_time.to_i - now.to_time.to_i)/TIME_UNIT_TO_SECS[time_unit].to_f).round
            when :MONTHS
              0.step.find { |n| (date_time >> n) > now } -1
            when :YEARS
              0.step.find { |n| (date_time >> 12*n) > now } -1
            else
              raise ArgumentError, "Invalid value for 'time_unit'"
            end
        if v == 0
          "Heute"
        else
          "in #{v} #{TIME_UNIT_LBLS[time_unit]} "          
        end
      end
    end
  end
end

class Time
  include PrettyDate::HumanTime
end

class Date
  include PrettyDate::HumanTime
end
