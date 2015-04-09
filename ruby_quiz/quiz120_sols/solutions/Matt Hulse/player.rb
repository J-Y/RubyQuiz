#file: player.rb
#author: Matt Hulse - www.matt-hulse.com

require 'hand'

class Player
  attr_reader :player_num, :right, :left, :strategy, :game
  def initialize(player_num, strategy, game)
    @player_num = player_num
    @strategy = strategy
    @game = game
    @right = Hand.new(:right,1)
    @left = Hand.new(:left,1)
  end

  def move
    begin
      eval(@strategy)
    rescue NameError => e
      random #default to random
    end
  end

  def get_opponent
    @game.get_opponent(self)
  end

  def get_larger_hand
    return @right if @right.finger_count > @left.finger_count
    return @left
  end

  def min(a,b)
    return a if a <= b
    return b
  end

  def random
    #all possible moves, choose randomly among them
    opponent = get_opponent

    valid_moves = Array.new

    opp_rt_count = opponent.right.finger_count
    opp_lt_count = opponent.left.finger_count

    if(@right.finger_count > 0) then
      valid_moves << "@right.touch(opponent.right)" if opp_rt_count > 0
      valid_moves << "@right.touch(opponent.left)" if opp_lt_count > 0
      #total on hand transferred to cannot be more than 5
      #random number is between 1 and the minimum of what left can receive and right can give
      rand_max = min(5-@left.finger_count,@right.finger_count-1)
      valid_moves << "@right.clap(@left, #{rand(rand_max) + 1})" if rand_max > 0
    end

    if(@left.finger_count > 0) then
      valid_moves << "@left.touch(opponent.right)" if opp_rt_count > 0
      valid_moves << "@left.touch(opponent.left)" if opp_lt_count > 0
      #total on hand transferred to cannot be more than 5
      #random number is between 1 and the minimum of what right can receive and left can give
      rand_max = min(5-@right.finger_count,@left.finger_count-1)
      valid_moves << "@left.clap(@right, #{rand(rand_max) + 1})" if rand_max > 0
    end

    move = valid_moves[rand(valid_moves.size)]
    eval(move)
    puts "Player #{player_num}: #{move}" if $DEBUG
  end

  def aggressive
    opponent = get_opponent

    #every move is to touch the opponents largest hand with the local largest hand
    move = "get_larger_hand.touch(opponent.get_larger_hand)"

    eval(move)
    puts "Player #{player_num}: #{move}" if $DEBUG
  end

  def to_s
    "#{player_num}: #{@left} #{@right}"
  end
end
