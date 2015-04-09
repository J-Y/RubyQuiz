require 'open-uri'

if $0 == __FILE__
  if ARGV.length < 1
    puts "Usage: #$0 <zip code>"
    exit(1)
  end
  parse_list = [[/<B>Local Forecast for (.* \(\d{5}\))<\/B>/, 'Local temperature for #$1: '],
    [/<B CLASS=obsTempTextA>([^&]*)&deg;(.)<\/B>/, '#$1 degrees #$2 '],
    [/<B CLASS=obsTextA>Feels Like<BR> ([^&]*)&deg;(.)<\/B>/, '[It feels like #$1 degrees #$2]']
  ]
  # Blessed be the internet, the great provider of information
  open('http://beta.weather.com/weather/local/'+ARGV[0]) do |io|
    html = io.read
    parse_list.each do |p|
      # We don't need no steenkin' HTML parser
      if html =~ p[0]
        print eval(%Q{"#{p[1]}"})
      end
    end
    puts
  end
end
