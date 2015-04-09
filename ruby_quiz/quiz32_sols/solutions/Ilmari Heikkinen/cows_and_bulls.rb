#!/usr/bin/ruby
=begin
  Cows and bulls game for Ruby Quiz #32 
  <http://www.rubyquiz.com/quiz32.html>

  Usage:
    cows_and_bulls.rb          # starts a new server on port 3085
    cows_and_bulls.rb hostname # connects as client to server on hostname
    cows_and_bulls.rb --local  # plays a non-networked game

  Implementation overview:
    Reads the words from /usr/share/dict/words, and asks a random word.
    The dict words and user replies are downcased and stripped of
    preceding & succeeding whitespace.
    Uses blocks for (somewhat) abstracting the reply-response protocol.

=end

require 'socket'

class CowsAndBulls

  attr_accessor :success, :failure, :words

  def initialize(success=1, failure=0, words=load_words)
    @success = success
    @failure = failure
    @words = words
  end

  def load_words
    File.readlines("/usr/share/dict/words").map{|w| w.strip.downcase}
  end

  def pick_word
    @words[rand(words.size)]
  end

  # Calls the player block first with word size,
  # the player block's return value is the player's
  # first guess.
  # Then calls the player block with "#{cows_count} #{bulls_count}"
  # until the player guesses right or exits the game by replying
  # "quit."
  # If the player solved the game, returns @success.
  # If the player quit, returns @failure.
  # 
  def play(word=pick_word, &player)
    reply = player.call(word.size).downcase.strip
    until word == reply or 'quit' == reply
      cb = cows_and_bulls word, reply
      stats = cb.join(" ")
      reply = player.call(stats).downcase.strip
    end
    return @failure if word != reply
    @success
  end

  def cows_and_bulls(word1, word2)
    b = bulls(word1, word2)
    w2 = word2.clone
    cows = word1.split('').inject(0){|sum, c|
      sum + (w2.sub!(c,'') ? 1 : 0)
    } - b
    [cows, b]
  end

  def bulls(word1, word2)
    word1.split('').zip(word2.split('')).inject(0){
      |sum, (a,b)|
      sum + (a == b ? 1 : 0)
    }
  end

end


class RemoteCowsAndBulls < CowsAndBulls

  # Create new RemoteCowsAndBulls proxy for socket connected
  # to a CowsAndBulls server.
  def initialize(socket, success=1, failure=0)
    super success, failure, nil
    @socket = socket
  end

  # Simulates a local CowsAndBulls game by
  # proxying the game events to @socket.
  #
  def play(&player)
    letters = @socket.gets.strip
    reply = player.call(letters)
    @socket.puts reply
    server_reply = @socket.gets.strip
    while server_reply.include?(" ")
      reply = player.call(server_reply)
      @socket.puts reply
      server_reply = @socket.gets.strip
    end
    if server_reply == "1"
      @success
    else
      @failure
    end
  end

end


class CabClient

  # Plays a game on the given server object.
  def self.play(server)
    first = true
    result = server.play{|server_reply|
      if first
        first = false
        puts "Amount of letters in word: #{server_reply}"
      else
        cb = server_reply.split(" ")
        puts "Cows: #{cb[0]}, Bulls: #{cb[1]}"
      end
      STDIN.gets
    }
    if result == server.success
      puts "Good job!"
    else
      puts "See you again..."
    end
  end

end


if __FILE__ == $0

  mode = nil
  if ARGV.empty?
    mode = :server
  else
    if ARGV[0] == '--local'
      mode = :local
    else
      mode = :client
    end
  end
  
  case mode
  when :local
    cab = CowsAndBulls.new
    CabClient.play(cab)
  when :server
    cab = CowsAndBulls.new
    server = TCPServer.new(3085)
    STDERR.puts "Running CowsAndBulls server on TCP port 3085"
    while sock = server.accept
      Thread.new(sock) do |s|
        begin
          STDERR.puts "Got client #{s.peeraddr.join(", ")}"
          result = cab.play{|server_reply|
            s.puts server_reply
            client_reply = s.readpartial(256)
            unless client_reply.include? "\n"
              msg = "Too long client reply, closing connection."
              STDERR.puts msg
              s.close
              raise msg
            end
            client_reply
          }
          s.puts result
          s.close
        rescue => e
          puts e, e.backtrace
        ensure
          s.close
        end
      end
    end
  when :client
    host = ARGV.shift
    sock = TCPSocket.new(host, 3085)
    cab = RemoteCowsAndBulls.new(sock)
    CabClient.play(cab)
  end

end
