require 'net/http'
require 'uri'
require 'rexml/document'

if ARGV.length == 0
  puts "Usage: ruby current_temp.rb [city, state | zipcode | city, country | airport code]"
  exit
end
urlbase = "http://www.wunderground.com/cgi-bin/findweather/getForecast?query="
zipcode = ARGV.join('%20')

# Search for the zipcode on wunderground website
response = Net::HTTP.get_response URI.parse(urlbase << zipcode)

# Parse the result for the link to a rss feed
rss_feed = String.new
# Get the line with rss feed
response.body.each do |line|
  if line.include?("application/rss+xml") then
    stop_pos  = line.rindex('"') - 1
    start_pos = line.rindex('"',stop_pos) + 1
    rss_feed  = line.slice(start_pos..stop_pos)
    break
  end
end
# Get the feed and parse it for city and weather information
# The response is different for US cities and places outside US.
# Use appropritate regular expression to parse both simultaneously
if rss_feed == "" then
  puts ARGV.join(' ') << ": No such city"
else
  feed     = Net::HTTP.get_response(URI.parse(rss_feed))
  document = REXML::Document.new feed.body
  title    = document.elements.to_a("//title")[0].text
  channel  = document.elements.to_a("//channel/item/description")[0].text
  city     = title.gsub(/\s*(Weather from)?\s*Weather Underground\s*(-)?\s*/,"")
  temp     = channel.gsub(/(^Temperature:|\|.*$|\W)/,"")
  temp     = temp.gsub("F", " degrees F / ").gsub("C", " degrees C")
# For exact format as asked in the quiz, uncomment the following
# temp     = temp.gsub("F.*$", "F")
  puts "The temperature in #{city} is #{temp}"
end
