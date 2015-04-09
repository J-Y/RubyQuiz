#!/usr/bin/ruby
#
# Choose a playing mode.
#


require 'tictactoe-interface'
require 'tictactoe-client'
require 'tictactoe-alphabeta'
require 'tictactoe-learning'

# Load experience if we have already learned something
def load_learned(player)
  if File::exists?("learned_#{player}.ai")
    Marshal.load(File.read("learned_#{player}.ai"))
  else
    Interface::Learning.new
  end
end

NI0 = Interface::NaturalIntelligence.new
NI1 = Interface::NaturalIntelligence.new
AB0 = Interface::AlphaBeta.new
AB1 = Interface::AlphaBeta.new
LE0 = load_learned(0)
LE1 = load_learned(1)
options_local = [['human vs. human', [NI0, NI1]],
  ['human vs. minimax', [NI0, AB1]],
  ['minimax vs. human', [AB0, NI1]],
  ['minimax vs. minimax', [AB0, AB1]],
  ['learned vs. human', [LE0, NI1]],
  ['human vs. learned', [NI0, LE1]]]

options_networked = [['human', [NI0, NI1]],
  ['minimax', [AB0, AB1]],
  ['learned', [LE0, LE1]]]

loop do
  puts "Play Tic Tac Toe"
  begin
    print "Do you want to play _local_ or in the _network_ [ln]: "
    decision = gets.downcase.strip
  end until /^[ln]$/ =~ decision

  if decision == 'l' # LOCAL
    begin
      puts "Select a game:"
      options_local.each_with_index do |(t, o), i| puts "  #{i+1}) #{t}" end
      print "[1-#{options_local.length}]: "
      selection = Integer(gets) - 1
      raise 'Invalid choice' if selection < 0 or options_local.length <= selection 
    rescue
      puts "Invalid choice"
      retry
    end
    play_game(*options_local[selection][1])
  else # NETWORKED
    print "Input server (Default localhost): "
    server = gets.strip
    server = 'localhost' if server == ''

    print "Input prot (Default 1276): "
    port = gets.to_i
    port = 1276 if port == 0
    
    begin
      puts "Select a player:"
      options_networked.each_with_index do |(t, o), i| puts "  #{i+1}) #{t}" end
      print "[1-#{options_networked.length}]: "
      selection = Integer(gets) - 1
      raise 'Invalid choice' if selection < 0 or options_local.length <= selection 
    rescue
      puts "Invalid choice"
      retry
    end

    client = TicTacToeClient.new(server, port)

    client.assign_player(options_networked[selection][1][client.player_number])
    client.play
  end
end
