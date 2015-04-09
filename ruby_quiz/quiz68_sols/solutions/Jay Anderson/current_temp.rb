require 'rexml/document'
require 'open-uri'

LOC_MATCH = /\/forecast\/([^.]+)\.html/

#Searches Yahoo and returns an array of location ids
def yahoo_loc_search(loc)
    return [loc] if loc =~ /\d/ #places usually don't have numbers in their names
    locs = []
    open("http://weather.yahoo.com/search/weather2?p=#{URI.escape(loc)}") do |http|
        return [$1] if http.base_uri.to_s =~ LOC_MATCH
        http.each {|line| locs << $1 if line =~ LOC_MATCH }
    end
    locs
end

#Returns a hash containing the location and temperature information
#Accepts US zip codes or Yahoo location id's
def yahoo_weather_query(loc_ids, units)
    weather = []
    loc_ids.each do |l|
        h = {}
        open("http://xml.weather.yahoo.com/forecastrss?p=#{l}&u=#{units}") do |http|
            response = http.read
            doc = REXML::Document.new(response)
            channel = doc.root.elements['channel']
            title = channel.elements['title'].text
            if title !~ /Error/ then
                location = channel.elements['yweather:location']
                h[:city] = location.attributes["city"]
                h[:region] = location.attributes["region"]
                h[:country] = location.attributes["country"]
                h[:temp] = channel.elements["item"].elements["yweather:condition"].attributes["temp"]
                weather << h
            end
        end
    end
    weather
end

if ARGV.length < 1 then
    puts "usage: #$0 <location> [f|c]"
    exit
end
loc_id = ARGV[0]
units = (ARGV[1] || 'f').downcase
units = (units =~ /^(f|c)$/) ? units : 'f'

loc_ids = yahoo_loc_search(loc_id)
weather_info = yahoo_weather_query(loc_ids, units)

puts "No matches found" if weather_info.size == 0

weather_info.each do |w|
    city = w[:city]
    region = w[:region]
    country = w[:country]
    temp = w[:temp]

    final_loc = "#{city}, #{region}#{', ' if region!="" and country!=""}#{country}"
    puts "The temperature in #{final_loc} is #{temp} degrees #{units.upcase}"
end
