#! /usr/bin/env ruby
# == Synopsis
# paste [options] ruby_source.rb   : Sends ruby_source.rb tp nopaste (rafb.net)
# == Usage
# -h, --help: 
#  Print this help
# -d, --desc:
#  The description to use
# -t, --text:
#  (optional: ruby string to paste) 
# -l, --lang:
#  (optional: language - defaults to Ruby. Can also use 'Plain Text')
# -n, --nick:
#  (optional: nickname - defaults to Anonymous)
# -r, --rubyurl:
#  (optional: posts url through http://rubyurl)


require 'getoptlong'
require 'rdoc/usage'
require 'yaml'
require 'net/http'
require 'uri'

fnconfig=File.expand_path "~/.paste.yml"
yml=YAML::load(File.open(fnconfig)) unless !File.exists?(fnconfig)

$rafb_url="http://rafb.net"
def location(response)
	"#{$rafb_url}#{response['location']}"
end

opts = GetoptLong.new(
	['--help', '-h', GetoptLong::NO_ARGUMENT],
	['--desc', '-d', GetoptLong::REQUIRED_ARGUMENT],
	['--text', '-t', GetoptLong::REQUIRED_ARGUMENT],
	['--nick', '-n', GetoptLong::REQUIRED_ARGUMENT],
	['--lang', '-l', GetoptLong::REQUIRED_ARGUMENT],
	['--rubyurl', '-r', GetoptLong::NO_ARGUMENT])

post_args = {}
yml['rafb'].each {|k,v| post_args[k] = v}

opts.each do |opt, arg|
	if opt == '--help'
		RDoc::usage
	else
		post_args[opt[2..-1]]=arg
	end
end

post_args['text'] ||= ARGF.readlines
post_args['lang'] ||= 'Ruby'

response = Net::HTTP.post_form URI.parse("#{$rafb_url}/paste/paste.php"),
	 post_args

case response
	when Net::HTTPSuccess
		puts response.body
	when Net::HTTPRedirection
		if post_args['rubyurl']
			puts Net::HTTP.get_response("rubyurl.com",
			   "/rubyurl/remote?website_url=" +
				location(response))['location'].sub("rubyurl/show","")
		else
			puts location(response)
		end
	else
		puts "error"
end