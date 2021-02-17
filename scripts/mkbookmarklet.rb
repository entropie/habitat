#!/usr/bin/env ruby

require "uri"
require "uglifier"

ENDPOINT = "http://xeno:2306/api/post/new"
TKN = "eyJhbGciOiJIUzI1NiJ9.eyJwYXNzd29yZCI6IiQyYSQxMCRVZ2Q5L2V2dmdmci94UE15WG5QMUt1OUI4bVlXL3JOd2E1ZXBFaDBDM1pZWlFucGFGd0FvQyIsInVzZXJfaWQiOiJSWXpxdDBCOEM1R3VjMlpXZmI3U1BhT0tVSXZUb2R3SiJ9.d4sl5Oq6d09e9SVWlc1SmohLWXV3QWpV5kVDttdOEe8"


str = <<-JAVASCRIPT
javascript:
    var url = encodeURI(document.location.href);
    var endp = "#{ENDPOINT}";
    var token = "#{TKN}";

    document.location.href=endp + "?token=" + token + "&s=" + url;
JAVASCRIPT




                      
puts "javascript:(function(){%s}());" % Uglifier.compile(str, :mangle => false)
                      
