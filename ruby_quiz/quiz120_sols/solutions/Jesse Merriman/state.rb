#!/usr/bin/env ruby
# state.rb
# Ruby Quiz 120: Magic Fingers

require 'constants'
require 'outcome'
require 'set'

# Represents one state of the game, which includes how many fingers are on each
# player's hands, and whose turn it is. States can also have parents, and a
# best_outcome can be assigned to them, though this class doesn't do anything
# with that itself. The player's hands are always sorted, since it doesn't
# matter having 3-left and 2-right is equivalent to 2-left and 3-right. When
# comparing states with ==, eql?, or their hashes, only @players and @turn are
# taken into account.
class State
  attr_reader :players, :turn, :parent, :best_outcome
  attr_writer :best_outcome

  # player_1 and player_2 are Arrays of number-of-fingers on each hand.
  def initialize(player_1, player_2, turn, parent = nil)
    @players = [player_1, player_2]
    @turn = turn
    @parent = parent
    @touch_reachable = @clap_reachable = nil

    for player in @players do
      State.normalize(player)
    end

    if end_state?
      @best_outcome = (self.winner == Player1 ? Outcome::P1Win : Outcome::P2Win)
    else
      @best_outcome = Outcome::Unknown
    end

    self
  end

  def hand_alive?(player_num, hand_num)
    @players[player_num][hand_num] > 0
  end

  def player_alive?(player_num)
    hand_alive?(player_num, Left) or hand_alive?(player_num, Right)
  end

  # true if at least one player is dead.
  def end_state?
    not player_alive?(Player1) or not player_alive?(Player2)
  end

  # Return the winner. This should only be called on end states (otherwise,
  # it'll always return Player1).
  def winner
    player_alive?(Player1) ? Player1 : Player2
  end

  # Turn the given player's hand into a fist if it has >= FingesPerHand
  # fingers up, and sort the hands.
  def State.normalize(player)
    for hand_num in [Left, Right] do
      player[hand_num] = 0 if player[hand_num] >= FingersPerHand
    end
    player.sort!
  end

  # Return a nice string representation of a player.
  def player_string(player_num)
    player = @players[player_num]
    '-' * (FingersPerHand-player[Left]) +
      '|' * player[Left] +
      '  ' +
      '|' * player[Right] +
      '-' * (FingersPerHand-player[Right])
  end

  # Return a nice string representation of this state (including both player
  # strings).
  def to_s
    s = "1: #{player_string(Player1)}"
    s << ' *' if @turn == Player1
    s << "\n2: #{player_string(Player2)}"
    s << ' *' if @turn == Player2
    s
  end

  # Return a compact string representation.
  def to_compact_s
    if @turn == Player1
      "[#{@players[Player1].join(',')}]* [#{@players[Player2].join(',')}]"
    else
      "[#{@players[Player1].join(',')}] [#{@players[Player2].join(',')}]*"
    end
  end

  # Equality only tests the players' hands and the turn.
  def ==(other)
    @players == other.players and @turn == other.turn
  end

  # Both eql? and hash are defined so that Sets/Hashes of states will only
  # differentiate states based on @players and @turn.
  def eql?(other); self == other; end
  def hash; [@players, @turn].hash; end

  # Yield once for each ancestor state, starting from the oldest and ending on
  # this state.
  def each_ancestor
    ancestors = [self]
    while not ancestors.last.parent.nil?
      ancestors << ancestors.last.parent
    end
    ancestors.reverse_each { |a| yield a }
  end

  # Have one player (the toucher) touch the other player (the touchee).
  def State.touch(toucher, toucher_hand, touchee, touchee_hand)
    touchee[touchee_hand] += toucher[toucher_hand]
  end

  # Yield each state reachable from this state by a touch move.
  def each_touch_reachable_state
    if @touch_reachable.nil?
      # Set to avoid duplicates.
      @touch_reachable = Set[]

      player = @players[@turn]
      opponent_num = (@turn + 1) % 2
      opponent = @players[opponent_num]

      for player_hand in [Left, Right] do
        for opponent_hand in [Left, Right] do
          if hand_alive?(@turn, player_hand) and
              hand_alive?(opponent_num, opponent_hand)
            op = opponent.clone # because touch modifies it
            State.touch(player, player_hand, op, opponent_hand)
            if @turn == Player1
              @touch_reachable << State.new(player, op, opponent_num, self)
            else
              @touch_reachable << State.new(op, player, opponent_num, self)
            end
          end
        end
      end
    end

    @touch_reachable.each { |r| yield r }
  end

  # Yield each state reachable from this state by a clap move.
  def each_clap_reachable_state
    if @clap_reachable.nil?
    # Set to avoid duplicates.
      @clap_reachable = Set[]
      player = @players[@turn]
      opponent_num = (@turn + 1) % 2
      opponent = @players[opponent_num]

      # Clap rules.
      for source_hand in [Left, Right] do
        target_hand = (source_hand == Left ? Right : Left)
        # The first line is the number that can be removed from the source.
        # The second is the number that can be added to the target without
        # killing it.
        max_transfer = [player[source_hand],
                      (FingersPerHand - player[target_hand] - 1)].min
        (1..max_transfer).each do |i|
          # skip transfers that just flip the hands
          next if (player[source_hand] - i) == player[target_hand]

          p = player.clone
          p[source_hand] -= i
          p[target_hand] += i
          if @turn == Player1
            @clap_reachable << State.new(p, opponent.clone, opponent_num, self)
          else
            @clap_reachable << State.new(opponent.clone, p, opponent_num, self)
          end
        end
      end
    end

    @clap_reachable.each { |r| yield r }
  end

  # Yield once for each state reachable from this one.
  def each_reachable_state
    each_touch_reachable_state { |r| yield r }
    each_clap_reachable_state  { |r| yield r }
  end
end
