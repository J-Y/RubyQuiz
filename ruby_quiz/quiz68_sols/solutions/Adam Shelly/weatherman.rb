require 'net/http'
require 'simple-rss'

class Object
  def metaclass; class << self; self; end; end
end                               #thanks, _why

#Extends Simple RSS to add tag attributes as methods to the tag object
#   given <sometag var="2">hello</sometag>,
#   allows item.sometag ==> hello
#   and item.sometag.var ==> 2
class SimpleRSSwAttributes < SimpleRSS
  def clean_content(tag, attrs, content)
    s=  super
    while n= (attrs =~ /((\w*)="([^"]*)" )/mi)
      attr_name = clean_tag($2)
      s.metaclass.send(:attr_reader,  attr_name)
      s.instance_variable_set("@#{attr_name}",unescape($3))
      attrs.slice!(n,$1.length)
    end
    s
  end
  def method_missing meth
    nil
  end
end

#Simple RSS feed reader.
# takes url, array of custom tags, and optional filename for caching results
# provides #each_item and #item(title) methods

class RSSFeeder
  def initialize feed_url, extra_tags=[], cache=nil
    raise 'Invalid URL' unless feed_url =~ /(.*\w*\.\w*\.\w*)(\/.*)/  #separate host, rest
    @url,@feed = $1, $2
    @cache = cache
    extra_tags.each{|tag| SimpleRSSwAttributes.feed_tags << tag}
  end

  #tyields [item,channel] for item with title matching name
  def item name, &block
    fetch
    i=@data.items.find{|item| item.title =~ name} if @data
    yield [i,@data.channel] if i
  end
  def each_item &block
    fetch
    @data.items.each{|item| yield item}
  end

private
  def time_to_fetch?
        @timestamp.nil? || (@timestamp < Time.now)
  end

  def fetch
    #read the cache if we don't have data
    if !@data && @cache
      File.open(@cache, "r") {|f|
        @timestamp = Time.parse(f.gets)
        @data = SimpleRSSwAttributes.parse(f)
      } if File.exists?(@cache)
    end
    #only fetch data from net if current data is expired
    time_to_fetch? ? net_fetch : @data
  end

  def net_fetch
    text = Net::HTTP.start(@url).get(@feed).body
    @data = SimpleRSSwAttributes.parse(text)
    #try to create a reasonable expiration date. Defaults to 10 mins in future
    date = @data.lastBuildDate || @data.pubDate || @data.expirationDate || Time.now
    @timestamp = date + (@data.ttl ? @data.ttl.to_i*60 : 600)
    @timestamp = Time.now + 600 if @timestamp < Time.now

    File.open(@cache, "w+"){|f|
      f.puts @timestamp;
      f.write text
    } if @cache
  end
end


if __FILE__==$0
  exit(-1+puts("Usage #{$0} zipcode [-f]\nGives current temperature
for zipcode, "+
    "-f to get forecast too").to_i)  if ARGV.size < 1
  zipcode = ARGV[0]

  yahoo_tags = %w(yweather:condition yweather:location  yweather:forecast)
  w = RSSFeeder.new("xml.weather.yahoo.com/forecastrss?p=#{zipcode}",
    yahoo_tags, "yahoo#{zipcode}.xml")
  w.item(/Conditions/) { |item,chan|
    puts "The #{item.title} are:\n\t#{chan.yweather_condition.temp}F and "+
    "#{chan.yweather_condition.text}"
  }
  w.item(/Conditions/) { |item,chan|
    puts "\nThe forecast for #{chan.yweather_location.city}, "+
    "#{chan.yweather_location.region} for #{chan.yweather_forecast.day}, "+
    "#{chan.yweather_forecast.date} is:\n"+
    "\t#{chan.yweather_forecast.text} with a high of #{chan.yweather_forecast.high} "+
    "and a low of #{chan.yweather_forecast.low}"
  } if ARGV[1]=~/f/i
  #catch errors
  w.item(/not found/) { |item,chan| puts item.description }

  #Alternate feed
  #w2 = RSSFeeder.new("rss.weather.com/weather/rss/local/#{zipcode}?cm_ven=LWO&cm_cat=rss&par=LWO_rss")
  #w2.item(/Current Weather/){|item,rss|
  #   puts item.title,item.description.gsub(/&deg;/,248.chr)}
  #w2.item(/10-Day Forecast/){|item,rss|
  #   puts item.title,item.description.gsub(/&deg;/,248.chr)} if ARGV[1]=~/f/i

end
