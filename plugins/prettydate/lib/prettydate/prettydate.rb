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

    def to_human_time(sep = " &mdash; ")
      to_human + sep + strftime("%H:%M Uhr")
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

    def form_date
      format_string = "%Y/%m/%d %H:%M"
      strftime(format_string)
    end

  end
end

class Time
  include PrettyDate::HumanTime
end

class Date
  include PrettyDate::HumanTime
end
