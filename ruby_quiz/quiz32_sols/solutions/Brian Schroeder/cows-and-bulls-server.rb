#!/usr/bin/env ruby

# Cows and Bulls server classes and program
#
# (c) 2005 Brian Schröder
# http://ruby.brian-schroeder.de/quiz/cows-and-bulls/
#
# This code is published under the GPL. 
# See http://www.gnu.org/copyleft/gpl.html for more information

Thread.abort_on_exception = true

require 'socket'
require 'cows-and-bulls'

# A cows and bulls session acting on a stream. This may be a TCP/IP stream, but you can also feed any other stream.
class CowsAndBullsSession
  
  protected
  # Write a line to the stream
  def send(line)
    @stream.puts line rescue nil 
  end

  # Read a line from the stream
  def receive
    @stream.gets.chomp rescue nil
  end

  public
  # Yields self and closes the stream after the block. This allows you to do more than one game with the same stream
  def initialize(stream)
    @stream = stream    
    yield self
  ensure
    @stream.close
  end
  
  # Play a game of cows and bulls with the stream given on initialization
  def act(words)
    words = %w(cat cow cot hill hell help)
    @game = CowsAndBullsGame.new(words.random_pick)      
    send @game.word_length
    while @game.guess = receive
      break if @game.correct
      send @game.cows_and_bulls.join(" ")
    end
    send 1 
  end
end

# The Cows-and-Bulls TCP Server. Initialize with ip and port number and then call serve to serve
class CowsAndBullsServer < TCPServer  
  def initialize(host, port, words)
    super(host, port)
    @words = words
  end
  
  def serve
    while (session = self.accept)
      Thread.new(session) do | s | 
	CowsAndBullsSession.new(session) do | cb_session | 
	  cb_session.act(@words)
	end
      end
    end
  end
end

if __FILE__ == $0
  ip = ARGV[0] || '127.0.0.1'
  port = (ARGV[1] || 9988).to_i
  words = if File.exist?'words.dic' then File.read('words.dic').downcase.split else %w(cat dog car hell free over fine) end
  server = CowsAndBullsServer.new(ip, port, words)
  server.serve
end
