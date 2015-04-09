require 'net/http'
require 'rexml/document'

zip = ARGV[0].to_s

if zip.length > 0 then
  h = Net::HTTP.new('rss.weather.com', 80)
  resp, data = h.get('/weather/rss/local/'+zip, nil)

  doc = REXML::Document.new data
  doc.elements.each('rss/channel/item/title') { |element|
    if element.text[0,7] == 'Current' then
      puts element.text
      desc = element.get_elements('../description').to_s.strip
      puts desc.slice(22,desc.length-57).sub('&deg;', 'degrees')
    end
    }
else
  puts 'Need a ZIP code as a command line parameter.'
end
