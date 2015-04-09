#!/usr/local/bin/ruby -w

require "gserver"

class ChattyServer < GServer
	def initialize( port = 61676, *args )
		super(port, *args)
	end
	
	def serve( io )
		messages = Array[ "Hello there.",
		                  "Welcome to ChattyServer.",
		                  "Isn't this a lovely conversation we're having?",
		                  "Is this \e[31mred\e[0m?" ]
		
		loop do
			io.puts messages[rand(messages.size)]
			sleep 5
		end
	end
end

server = ChattyServer.new
server.start
server.join
