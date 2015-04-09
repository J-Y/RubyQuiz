#!/usr/bin/env ruby

require "webrick"

server = WEBrick::HTTPServer.new(:Port => 8080, :DocumentRoot => "cgi-bin")

['INT', 'TERM'].each do |signal|
	trap(signal) { server.shutdown }
end
server.start
