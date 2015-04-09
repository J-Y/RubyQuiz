# Author: Shane Emmons
#
# Allows retrieval of current temperature information. Pretty simple
# and straight forward. Uses match to extract data from the xml
# document that is returned. Adjusted for easier horizontal reading. ;-)
#
# usage: ruby current_temp.rb [zipcode|other]
#
# zipcode:  US zipcode
# other:    country code information.
#               example: SPXX0050 for Madrid, Spain

require 'net/http'

begin
    info = Net::HTTP.get(
        "xml.weather.yahoo.com", "/forecastrss?p=".concat( ARGV[ 0 ] )
    )

    location    = info.match( /Yahoo! Weather for (.*)</ )[ 1 ]
    temperature = info.match( /<yweather:condition.*temp="(\d+)"/ )[ 1 ]
    measured_in = info.match( /<yweather:units temperature="(.)"/ )[ 1 ]

    print "The temperature in ",
        location, " is ", temperature, " degrees ", measured_in, ".\n"
rescue
    print "Information for #{ ARGV[ 0 ] } was not found or unavailable.\n"
end
