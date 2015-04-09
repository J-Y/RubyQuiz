#!/usr/local/bin/ruby -w

require "gserver"
require "cowsnbulls"
require "optparse"

class TelnetServer < GServer
	def self.handle_telnet( line, io )          # minimal Telnet implementation
		line.gsub!(/([^\015])\012/, "\\1")      # ignore bare LFs
		line.gsub!(/\015\0/, "")                # ignore bare CRs
		line.gsub!(/\0/, "")                    # ignore bare NULs

		while line.index("\377")                # parse Telnet codes
			if line.sub!(/(^|[^\377])\377[\375\376](.)/, "\\1")
				# answer DOs and DON'Ts with WON'Ts
				io.print "\377\374#{$2}"
			elsif line.sub!(/(^|[^\377])\377[\373\374](.)/, "\\1")
				# answer WILLs and WON'Ts with DON'Ts
				io.print "\377\376#{$2}"
			elsif line.sub!(/(^|[^\377])\377\366/, "\\1")
				# answer "Are You There" codes
				io.puts "Still here, yes."
			elsif line.sub!(/(^|[^\377])\377\364/, "\\1")
				# do nothing - ignore IP Telnet codes
			elsif line.sub!(/(^|[^\377])\377[^\377]/, "\\1")
				# do nothing - ignore other Telnet codes
			elsif line.sub!(/\377\377/, "\377")
				# do nothing - handle escapes
			end
		end
		
		line
	end
	
	def initialize( port = 61676, *args )
		super(port, *args)
	end
	
	def serve( io )
		game = WordGame.new
		io.puts "I'm thinking of a #{game.word_length} word."
		loop do
			io.print "Your guess?  "
			try = self.class.handle_telnet(io.gets, io)
			
			results = game.guess(try)
			if results == true
				io.puts "That's right!"
				
				io.print "Play again?  "
				if self.class.handle_telnet(io.gets[0], io) == ?y
					game = WordGame.new
					io.puts "I'm thinking of a #{game.word_length} letter word."
				else
					break
				end
			else
				cows = if results.first == 1
					"1 Cow"
				else
					"#{results.first} Cows"
				end
				bulls = if results.last == 1
					"1 Bull"
				else
					"#{results.last} Bulls"
				end
				io.puts "#{cows} and #{bulls}"
			end
		end
	end
end

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

server = TelnetServer.new(listen_port)
server.start
server.join
