#!/usr/bin/ruby
require 'uri'
require 'net/http'

result = Net::HTTP.post_form(URI.parse('http://rafb.net/paste/paste.php'),
                            {:text => ARGF.readlines,
                             :nick => 'paste user',
                             :lang => 'Ruby'})
result = Net::HTTP.get_response 'rubyurl.com',
                              '/rubyurl/remote?website_url=http://rafb.net' + result['location']
puts result['location'].sub('rubyurl/show/', '')
