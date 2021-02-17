#!/usr/bin/env ruby

require "uri"
require "uglifier"

TKN = ARGV.join

raise "no endpoint" unless ENV["ENDPOINT"]

ENDPOINT = ENV["ENDPOINT"]

str = <<-JAVASCRIPT
javascript:
    var url = encodeURI(document.location.href);
    var endp = "#{ENDPOINT}";
    var token = "#{TKN}";

    document.location.href=endp + "?token=" + token + "&s=" + url;
JAVASCRIPT


puts
puts "javascript:(function(){%s}());" % Uglifier.compile(str, :mangle => false)
                      
