#!/usr/bin/env ruby

# Cows and Bulls client classes and program
#
# (c) 2005 Brian Schröder
# http://ruby.brian-schroeder.de/quiz/cows-and-bulls/
#
# This code is published under the GPL. 
# See http://www.gnu.org/copyleft/gpl.html for more information

require 'socket'
require 'readline'
require 'cows-and-bulls'

# Cows and Bulls readline UI
class ReadlinePlayer
  include Readline

  def initialize
    puts "Welcome to a game of cows and bulls"
  end

  def server
    server = readline("To which server shall I connect [127.0.0.1:9988]? ")
    return ['127.0.0.1', 9988] if server == ''
    raise "Invalid server address" unless /^([^:]*):(\d+)$/ =~ server
    [$1, $2.to_i]
  end

  def word_length(length)
    puts "The server has picked a word with #{length} letter"
  end

  def cows_and_bulls(cows, bulls)
    puts "Your pick includes #{cows} cows and #{bulls} bulls"
  end

  def correct
    puts "That was correct!"
  end

  def pick_word
    readline("Please pick a word> ")
  end

  def local_game?
    /^l(|o(|c(|a(|l))))/i =~ readline("Local or remote game? [lr] ") 
  end

  def connection_refused
    puts "The connection was refused, try another server."
  end
end

# User interface that uses a AI to pick the words
require 'set'
class DumbAIPlayer < ReadlinePlayer
  
  def initialize
    super
    @experience = {}
    @dead_horses = Set.new
  end

  def word_length(length)
    @length = length
    super
  end

  def cows_and_bulls(cows, bulls)
    @experience[@guess] = [cows, bulls]
    # Do some intelligence here
    @dead_horses += @guess.split('') if cows + bulls == 0
    super
  end

  def pick_word
    letters = (('a'..'z').to_a.to_set - @dead_horses).to_a
    @guess = Array.new(@length) { letters.random_pick }.join
    puts "Picked: #{@guess}"
    @guess
  end
end

class CowsAndBullsNetworkGame < TCPSocket
  def initialize(host, port)
    super(host, port)
    @word_length = gets.to_i
  end

  # Make a guess
  def guess=(guess)
    puts guess
    case gets
    when /^(\d+) (\d+)$/      
      @cows = $1.to_i
      @bulls = $2.to_i
      @correct = false
    when /^1$/
      @correct = true
    end
  end

  # Return the length of the picked word
  def word_length
    @word_length
  end

  # Return number of cows and bulls in current guess
  def cows_and_bulls
    [@cows, @bulls]
  end

  # True iff current guess is correct
  def correct
    @correct
  end
end

class CowsAndBullsClient
  def initialize(ui)
    @ui = ui
    connect
    begin
      act
    ensure
      disconnect
    end
  end

  def act
    @ui.word_length @game.word_length
    begin
      @game.guess = @ui.pick_word
      @ui.cows_and_bulls(*@game.cows_and_bulls) unless @game.correct
    end until @game.correct
    @ui.correct
  end
end 


class CowsAndBullsLocalClient < CowsAndBullsClient
  def initialize(ui, words)
    @words = words
    super(ui)
  end

  def connect
    @game = CowsAndBullsGame.new(@words.random_pick)
  end

  def disconnect
  end
end

class CowsAndBullsNetworkClient < CowsAndBullsClient
  def connect    
    host, port = *@ui.server
    @game = CowsAndBullsNetworkGame.new(host, port)
  rescue Errno::ECONNREFUSED 
    @ui.connection_refused
    connect 
  end

  def disconnect
    @game.close
  end
end


if __FILE__ == $0
  player = ARGV[0] == '--ai' ? DumbAIPlayer : ReadlinePlayer
  player = player.new
  if player.local_game?
    words = if File.exist?'words.dic' then File.read('words.dic').downcase.split else %w(cat dog car hell free over fine) end
    server = CowsAndBullsLocalClient.new(player, words)
  else
    server = CowsAndBullsNetworkClient.new(player)
  end
end
