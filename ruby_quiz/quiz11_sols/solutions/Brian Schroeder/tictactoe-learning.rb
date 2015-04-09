#!/usr/bin/ruby
#
# Learn the rules and optimal moves for tictactoe!
#
# Another non-learning implementation is Interface::AlphaBeta
#
# If you execute this file, it will train two player AI's and output statistics to STDOUT and STDERR.
#
# See also the +train+ and the +makeplots+ scripts.

require 'tictactoe-interface'

module Interface
  # Learning version. For a description see http://ruby.brian-schroeder.de/quiz/tictactoe/
  class Learning < BasicInterface
    attr_accessor :random_prob
    attr_reader :player
      
    def initialize
      @state_values = Hash.new(0)
      @state_transitions = {}
      @random_prob = 0.05
    end

    def new_game(player)
      @player = player
      @states_visited = []        
    end
    
    def choose_move(game)
      moves = game.moves
      if !@state_transitions[game.state_id] or rand < random_prob # Pick a random move
        move = moves[rand(moves.length)]
      else # Pick the best move
        move_id = @state_transitions[game.state_id].max{ | (ma, sa), (mb, sb) | @state_values[sa] <=> @state_values[sb] }[0]
        move = moves.select{|m| m.move_id == move_id}[0]
      end
      move
    end

    def inform_of_move(before, after, move)          
      @states_visited << before.state_id << after.state_id
      (@state_transitions[before.state_id] ||= {})[move.move_id] = after.state_id
      
      if after.final?
        winner = after.winner
        if winner
          value = winner == self.player ? 100.0 : -1000.0
        else
          value = 0.0
        end
        
        factor = 1.0
        while state = @states_visited.pop
          @state_values[state] = (1.0 - factor) * @state_values[state] + factor * value
          factor *= 0.5
        end
      end
    end
  end
end

# If this file is executed, train learning version on random and alphabeta opponents and
# then start a game against the human.
if __FILE__ == $0
  require 'tictactoe-alphabeta'
  $stdout.sync = true

  # Load experience if we have already learned something
  def load_learned(player)
    if File::exists?("learned_#{player}.ai")
      Marshal.load(File.read("learned_#{player}.ai"))
    else
      Interface::Learning.new
    end
  end

  def save_learned(ai)
    File.open("learned_#{ai.player}.ai", 'w') { | f | f.write(Marshal.dump(ai)) }
  end    

  def play_n_games(n, ai0, ai1)
    wins, losses, draws = 0, 0, 0
    n.times do
      result = play_game_silent(ai0, ai1)
      case result
      when 0: wins += 1
      when 1: losses += 1
      else draws += 1
      end
    end
    return wins, losses, draws
  end
  
  ai0 = load_learned(0)
  ai0.random_prob = 0.10
  ai1 = load_learned(1)
  ai1.random_prob = 0.10

  optimal = Interface::AlphaBeta.new

  bar_width = 20
  stepsize = 500
  iterations = 60
  optimal_tests = 40
  puts "Learning from #{iterations * stepsize} games."
  $stderr.puts ['Type', 'Iteration', 'Wins', 'Losses', 'Draws', 'Plays'].map{|s|s.to_s.ljust(15)}.join("\t")

  puts 'Learning: ' + ["Player 0 won", 'Player 1 won', 'Draw'].map{|s| s.ljust(bar_width)}.join(' | ') + '  |  ' +
    "Optimal: " + ["Learning won", 'Optimal won', 'Draw'].map{|s| s.ljust(bar_width)}.join(' | ')
  iterations.times do | i |
    # Explore less, when we have more experience.
    ai0.random_prob = 0.05 + 0.05 * (1.0 - (i.to_f / iterations.to_f))
    ai1.random_prob = 0.05 + 0.05 * (1.0 - (i.to_f / iterations.to_f))
    
    wins, losses, draws = *play_n_games(stepsize, ai0, ai1)
    print '          ' +  [wins, losses, draws].map{|v| ("%6.2f%%" % (100 * v.to_f / optimal_tests.to_f)).ljust(bar_width)}. join(' | ')
    $stderr.puts ['Train:', i+1, wins, losses, draws, stepsize].map{|s|s.to_s.ljust(15)}.join("\t")

    # Validate against optimal player
    ai0.random_prob = 0.00
    wins, losses, draws = *play_n_games(optimal_tests, ai0, optimal)
    puts '  |  ' + '         ' +
      [wins, losses, draws].map{|v| ("%6.2f%%" % (100 * v.to_f / stepsize.to_f)).ljust(bar_width)}. join(' | ')
    $stderr.puts ['Validate:', i+1, wins, losses, draws, stepsize].map{|s|s.to_s.ljust(15)}.join("\t")

    # Save Experience to disk
    save_learned(ai0)
    save_learned(ai1)
  end

#  puts "Now lets see if you dare to play against me..."
#  ai0.random_prob = 0.0
#  player1 = Interface::NaturalIntelligence.new
#  play_game(ai0, player1)

  # Save Experience to disk
#  save_learned(ai0)
end
