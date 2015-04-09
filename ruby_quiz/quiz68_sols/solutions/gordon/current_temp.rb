# current_temp.rb

require 'net/http'
require 'rexml/document'
require 'optparse'
require "rubygems"
require "highline/import"
require 'cgi'

class LocationSearch
  attr_reader :loc

  def initialize(string)
    city = CGI.escape(string)

    h = Net::HTTP.new('weather.yahoo.com', 80)
    resp, data = h.get("/search/weather2?p=#{city}", nil)

    case resp
      when Net::HTTPSuccess     then @loc = location_menu( parse_locations(data) )
      when Net::HTTPRedirection then @loc = get_location(resp['location'])
    end
  end

  def location_menu(hash)
    choose do |menu|
      menu.prompt = "Please choose your location  "
      hash.each do |key,val|
        menu.choice val do return key end
      end
    end
  end

  def parse_locations(data)
    a = {}
    data.split("\n").each do |i|
       a[get_location(i)]=strip_html(i) if /a href="\/forecast/ =~ i
     end
     a
  end

  def strip_html(str)
    str = str.strip || ''
    str.gsub(/<(\/|\s)*[^>]*>/,'')
  end

  def get_location(string)
    string.split(/\/|\./)[2]
  end

end


class CurrentTemp
  include REXML

  def initialize(loc,u='f')
    uri = "http://xml.weather.yahoo.com/forecastrss?p=#{loc}&u=#{u}"
    @doc = Document.new Net::HTTP.get(URI.parse(uri))
    raise "Invalid city, \"#{loc}\"" if /error/i =~ @doc.elements["//description"].to_s
  end

  def method_missing(methodname)
    XPath.match(@doc,"//*[starts-with(name(), 'yweather')]").each do|elem|
      return elem.attributes[methodname.to_s] if elem.attributes[methodname.to_s]
    end
    Object.method_missing(methodname)
  end

  def unit
    self.temperature
  end

  def state
    self.region
  end

  def to_s
    "The current temperature in #{self.city}, #{self.state} is #{self.temp} degrees #{self.unit}."
  end

end

begin

  opts = OptionParser.new
    opts.banner = "Usage:\n\n    current_temp.rb city [-u unit]\n\n"
    opts.banner += "city should be a zip code, or a Yahoo Weather location id.\n\n"
    opts.on("-uARG", "--unit ARG","Should be f or c", String) {|val| @u = val }
    opts.on("-s", "--search","Search location") {@search = true}
    opts.on("-h", "--help")  {puts opts.to_s ; exit 0}

  loc = opts.parse!.to_s
  @u ||='f'

  if @search
    loc = LocationSearch.new(loc).loc
  end

  if loc.empty?
    raise "Invalid city, \"#{loc}\""
  else
    puts
    puts CurrentTemp.new(loc,@u)
  end

rescue 
  puts $!
  puts opts.to_s
  exit 1
end
