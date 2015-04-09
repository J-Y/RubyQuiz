#!/usr/bin/env ruby

require 'lazy'
require 'soap/wsdlDriver'
require 'rexml/document'
$-w = nil

$wsdl_loc = "http://www.webservicex.net/globalweather.asmx?WSDL"
class WeatherState
  def initialize(city, country)
    stub = SOAP::WSDLDriverFactory.new($wsdl_loc).create_rpc_driver

    @keep_me = promise do
      conditions = stub.getWeather(:CityName =>city, :CountryName=>country)
      data = REXML::Document.new(conditions.getWeatherResult.gsub(/<\?.*?>\n/, ''))
      { :temp => data.elements["//Temperature"].text, loc => data.elements["//Location"].text }
      end
    end

    def temp
      demand(@keep_me)[:temp]
    end

    def loc
      demand(@keep_me)[:loc]
    end
end

if ARGV.length != 2
  abort("Usage: weather.rb city country")
end

# Create Weather Object
weatherProxy = WeatherState.new(ARGV[0], ARGV[1])
puts "Location: " + weatherProxy.loc
puts "Current Temp: " + weatherProxy.temp.strip
