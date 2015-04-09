#!/usr/bin/env ruby

require "webrick"
require "cowsnbulls"
require "optparse"

listen_port = 61676
ARGV.options do |opts|
	opts.banner = "Usage:  #{File.basename($0)}  [OPTIONS]"
	
	opts.separator ""
	opts.separator "Specific Options:"
	
	opts.on( "-d", "--dictionary DICT_FILE",
	         "The dictionary file to pull words from." ) do |dict|
		WordGame.load_dictionary(dict)
	end
	opts.on( "-p", "--port PORT", Integer,
	         "The port to listen for connections on." ) do |port|
		listen_port = port
	end

	opts.separator "Common Options:"

	opts.on( "-h", "--help",
	         "Show this message." ) do
		puts opts
		exit
	end
end.parse!

server = WEBrick::HTTPServer.new(:Port => listen_port)

server.mount_proc("/") do |request, response|
	game = WordGame.new
	
	cookie = WEBrick::Cookie.new("word", game.word)
	cookie.expires = Time.now + 60 * 60
	response.cookies << cookie

	response.body = <<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Cows and Bulls</title>
</head>
<body>
	<p>I'm thinking of a #{game.word_length} letter word.</p>
	
	<form action="/guess" method="get">
		<p>Your guess?  <input name="try" type="text" /></p>
		<p><input type="submit" /></p>
	</form>
</body>
</html>
HTML
end

server.mount_proc("/guess") do |request, response|
	game = WordGame.new

	if saved_word = request.cookies.find { |c| c.name == "word" }
		game.word = saved_word.value
	end
	
	if request.query["try"] and not request.query["try"].empty?
		results = game.guess(request.query["try"])
		if results == true
			response.set_redirect(WEBrick::HTTPStatus::SeeOther, "/correct")
		end
	else
		response.set_redirect(WEBrick::HTTPStatus::SeeOther, "/")
	end

	response.body = <<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Cows and Bulls</title>
</head>
<body>
	<p>#{request.query["try"]}:
	   #{results.first == 1 ? "1 Cow" : "#{results.first} Cows"} and
	   #{results.last == 1 ? "1 Bull" : "#{results.last} Bulls"}</p>
	
	<form action="/guess" method="get">
		<p>Your guess?  <input name="try" type="text" /></p>
		<p><input type="submit" /></p>
	</form>
</body>
</html>
HTML
end

server.mount_proc("/correct") do |request, response|
	response.body = <<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Cows and Bulls</title>
</head>
<body>
	<p>That's right!  <a href="/">Play again?</a></p>
</body>
</html>
HTML
end

['INT', 'TERM'].each do |signal|
	trap(signal) { server.shutdown }
end
server.start
