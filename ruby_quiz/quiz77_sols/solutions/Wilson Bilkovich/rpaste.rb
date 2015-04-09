#/usr/bin/env ruby
require 'net/http'
require 'uri'
uri = URI.parse('http://rpaste.com/pastes')
response = Net::HTTP.post_form uri,
{'snippet[language]' => 'ruby', 'snippet[user_name]' => 'Rubyist',
'snippet[description]' => 'RubyQuiz',
'snippet[body]' => "def hello()\n puts 'Hello, Ruby Quiz'\nend"}
puts response.header['location']
