require 'net/http'
puts ((ARGV.length != 1) ? "Usage: #$0 <zip code>" :  (["The temperature
in"] + (/Weather<\/b> for <b>(.*)<\/b>.*\D(\d+)&deg;F/.match(Net::HTTP.get(
URI.parse("http://www.google.com/search?hl=en&q=temperature+#{ARGV[0]}")))[1,2].collect!
{|x| " is " + x})).to_s.gsub!(/in is /, "in ") + " degree F")
