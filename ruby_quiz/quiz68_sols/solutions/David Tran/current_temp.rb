require 'uri'
require 'open-uri'
require 'rexml/document'

class Weather
  attr_reader :location, :temperature, :unit

  def initialize(zip_or_city, unit='f')
    raise "Error: Unit must be 'C' or 'F'." unless unit =~ /^[cf]$/i
    id = get_id(zip_or_city)
    url = "http://xml.weather.yahoo.com/forecastrss/#{id}_#{unit.downcase}.xml"
    xml = open(url) { |f| f.read }
    doc = REXML::Document.new(xml)
    @temperature = doc.elements['/rss/channel/item/yweather:condition/@temp'].to_s.to_i
    @unit = unit.upcase
  end

  private
  def get_id(location)
    location = URI.escape(location)
    url = "http://xoap.weather.com/search/search?where=#{location}"
    xml = open(url) { |f| f.read }
    doc = REXML::Document.new(xml)
    locations = doc.elements.to_a("/search/loc")
    raise "Cannot find the location." if locations.size <= 0
    # raise "Please more specific:\n#{locations.map {|e| e.text}*"\n"}" if locations.size > 1
    @location = locations[0].text.sub(/\s*\(\d+\)\s*$/, '')
    locations[0].attributes['id']
  end
end

if __FILE__ == $0
  if ARGV.size <= 0 || (ARGV[1] && ARGV[1] !~ /^[cf]$/i)
    puts "Usage:  #$0  city_or_zip_code  [c|f]"
    exit(1)
  end

  begin
    w = Weather.new(ARGV[0], ARGV[1] || 'f')
    puts "The temperature in #{w.location} is #{w.temperature} degress #{w.unit}."
  rescue
    puts "Information for #{ARGV[0]} was not found or unavailable."
  end
end
