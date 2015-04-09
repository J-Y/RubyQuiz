require 'open-uri'
open("http://www.google.com/search?q=weather+#{ARGV.join('+')}") do |page|
  page.readlines.join =~ /<b>Weather<\/b> for <b>(.*?)<\/b>.*>(\d+)&deg;F/
  puts "The temperature in #{$1} is #{$2} degrees F."
end
