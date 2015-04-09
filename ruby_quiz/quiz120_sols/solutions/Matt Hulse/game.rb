#file: game.rb
#author: Matt Hulse - www.matt-hulse.com

require 'player'

class Game
  attr_reader :p1, :p2, :winner, :rounds

  def initialize(p1_strategy = "random", p2_strategy = "random")
    @p1 = Player.new(1,p1_strategy, self)
    @p2 = Player.new(2,p2_strategy, self)
    @rounds = 0
  end

  def get_opponent(player)
    return @p1 if @p2 == player
    return @p2 if @p1 == player
  end

  def loop
    #keep going until one person has no hands left
    #after 100 rounds we're calling a draw!

    puts self if $VERBOSE
    until(game_over) do
      @rounds += 1
      p1.move
      puts self if $VERBOSE

      unless game_over then
        p2.move
        puts self if $VERBOSE
      end
      break if @rounds >= 100
    end

    if(lost?(p1)) then
      @winner = p2
    elsif(lost?(p2))
      @winner = p1
    else
      puts "Draw"
    end
  end

  def game_over
    lost?(p1) || lost?(p2)
  end

  def lost?(player)
    player.left.finger_count <= 0 and player.right.finger_count <= 0
  end

  def to_s
    "#{p1}\n#{p2}\n"
  end
end
