#!/usr/local/bin/ruby -w

require "thread"
require "socket"
require "io/wait"

# utility method
def show_prompt
	puts "\r\n"
	print "#{$prompt} #{$output_buffer}"
	$stdout.flush
end

# prepare global (scriptable) data
$input_buffer  = Queue.new
$output_buffer = String.new

$end_session = false
$prompt      = ">"
$reader      = lambda { |line| $input_buffer << line.strip }
$writer      = lambda do |buffer|
	$server.puts "#{buffer}\r\n"
	buffer.replace("")
end

# open a connection
begin
	host = ARGV.shift || "localhost"
	port = (ARGV.shift || 61676).to_i
	$server = TCPSocket.new(host, port)
rescue
	puts "Unable to open a connection."
	exit
end

# eval() the config file to support scripting
config = File.join(ENV["HOME"], ".mud_client_rc")
if File.exists? config
	eval(File.read(config))
else
	File.open(config, "w") { |file| file.puts(<<'END_CONFIG') }
# Place any code you would would like to execute inside the Ruby MUD client at
# start-up, in this file.  This file is expected to be valid Ruby syntax.

# Set $prompt to whatever you like as long as it supports to_s().

# You can set $end_session = true to exit the program at any time.

# $reader and $writer hold lambdas that are passes the line read from the
# server and the line read from the user, respectively.
#
# The default $reader is:
# 	lambda { |line| $input_buffer << line.strip }
#
# The default $writer is:
# 	lambda do |buffer|
# 		$server.puts "#{buffer}\r\n"
# 		buffer.replace("")
# 	end

END_CONFIG
end

# launch a Thread to read from the server
Thread.new($server) do |socket|
	while line = socket.gets
		$reader[line]
	end
	
	puts "Connection closed."
	exit
end

# switch terminal to "raw" mode
$terminal_state = `stty -g`
system "stty raw -echo"

show_prompt

# main event loop
until $end_session
	if $stdin.ready?    # read from user
		character = $stdin.getc
		case character
		when ?\C-c
			break
		when ?\r, ?\n
			$writer[$output_buffer]

			show_prompt
		else
			$output_buffer << character

			print character.chr
			$stdout.flush
		end
	end
	
	break if $end_session
	
	unless $input_buffer.empty?   # read from server
		puts "\r\n"
		puts "#{$input_buffer.shift}\r\n" until $input_buffer.empty?

		show_prompt
	end
end

# clean up after ourselves
puts "\r\n"
$server.close
END { system "stty #{$terminal_state}" }
