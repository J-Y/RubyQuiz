require 'net/http'
require 'uri'

class Website
 def self.get(url)
   uri = URI.parse(url)
   begin
     res = Net::HTTP.start(uri.host, uri.port) do |http|
       http.get(uri.request_uri)
     end
     body = res.body
   rescue
     raise "Error: Failed to fetch page!"
   end
   return body
 end
end

if ARGV.first =~ /^[0-9]{5}$/
 content = Website.get("http://www.weather.com/weather/local/#{ARGV.first}")
 name = content.scan(/<br>([^>]+) \(#{ARGV.first}\)/i).first.first
else
 precontent = Website.get("http://www.weather.com/search/enhanced?what=WeatherLocalUndeclared&lswe=#{ARGV.join('+')}&lswa=WeatherLocalUndeclared&search=search&from=whatwhere&where=#{ARGV.join('+')}&whatprefs=&x=0&y=0")
 url, name = precontent.scan(%r#<b>1. <a href="/([^"]+)">([^<>]+)</a></b>#i).first
 content = Website.get("http://www.weather.com/#{url}")
end

begin
 temp = content.scan(%r#<b class="?obsTempTextA"?>([^<>]+)</b>#i).first.first.sub(/&deg;/, ' degrees ')
rescue
 puts("Go and check your other geek devices!")
end && puts("The temperatur in #{name} is #{temp}.")
