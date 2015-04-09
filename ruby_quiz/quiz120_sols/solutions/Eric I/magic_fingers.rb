HandNames = ["left hand", "right hand"]

AllowClapsToZero = false

Levels = 25


# Memo is used to store best moves for a given state to avoid
# re-calculation.  The key is a GameState, and the value is an array
# containing the number of levels used to calculate the best move, the
# best move, and the score of the best move.
Memo = Hash.new


# Instances of this class represent the game state.
class GameState
  attr_reader :hands

  def initialize(hands = [[1, 1], [1, 1]])
    @hands = hands
  end

  def do_turn(move)
    new_hands, description1, description2 =
      *move.call(@hands[0].dup, @hands[1].dup)
    [GameState.new([new_hands[1], new_hands[0]]),
      description1,
      description2]
  end

  def to_s
    result = ""
    @hands.each_index do |i|
      result << "#{i+1}: "
      result << '-' * (5 - @hands[i][0])
      result << '|' * @hands[i][0]
      result << ' '
      result << '|' * @hands[i][1]
      result << '-' * (5 - @hands[i][1])
      result << "\n"
    end
    result
  end

  def game_over?
    @hands[0][0] == 0 && @hands[0][1] == 0 ||
      @hands[1][0] == 0 && @hands[1][1] == 0
  end

  def score
    if @hands[0][0] == 0 && @hands[0][1] == 0 : -1
    elsif @hands[1][0] == 0 && @hands[1][1] == 0 : 1
    else 0
    end
  end

  def eql?(other)
    @hands == other.hands
  end

  def hash
    @hands[0][0] + 5 * @hands[0][1] + 25 * @hands[1][0] +
      125 * @hands[1][1]
  end
end


# Generates an array of Procs, each able to perform a touching move.
# Each Proc, when passed in the arrays representing the mover's hands
# and the opponent's hands returns an array containing the new states
# of the hands, a long description of the move, and an abbreviated
# description of the move.  If the move cannot legally be applied to
# the hands, an exception is raised.
def generate_touches
  result = []
  (0..1).each do |from_hand|
    (0..1).each do |to_hand|
      result << Proc.new do |player_hands, opponent_hands|
        raise "cannot touch from empty hand" if player_hands[from_hand] == 0
        raise "cannot touch to empty hand" if opponent_hands[to_hand] == 0
        description1 =
          "touches #{HandNames[from_hand]} to opponent's #{HandNames[to_hand]}"
        description2 = "#{player_hands[from_hand]}T#{opponent_hands[to_hand]}"
        opponent_hands[to_hand] += player_hands[from_hand]
        opponent_hands[to_hand] = 0 if opponent_hands[to_hand] >= 5
        [[player_hands, opponent_hands], description1, description2]
      end
    end
  end
  result
end


# Generates an array of Procs, each able to perform a clapping move.
# See the comment for generate_touches for the remaining details since
# this method works analogously.
def generate_claps
  result = []
  (0..1).each do |from_hand|
    to_hand = 1 - from_hand
    (1..4).each do |fingers|
      result << Proc.new do |player_hands, opponent_hands|
        raise "do not have enough fingers on #{HandNames[from_hand]}" unless
          player_hands[from_hand] >= fingers
        raise "#{HandNames[to_hand]} would end up with five or more fingers" if
          !AllowClapsToZero && player_hands[to_hand] + fingers >= 5
        raise "cannot end up with same number combination after clap" if
          player_hands[from_hand] - fingers == player_hands[to_hand]
        description1 = "claps to transfer #{fingers} fingers from " +
          "#{HandNames[from_hand]} to #{HandNames[to_hand]}"
        player_hands[from_hand] -= fingers
        player_hands[to_hand] += fingers
        player_hands[to_hand] = 0 if player_hands[to_hand] >= 5
        description2 = "C#{player_hands[from_hand]}#{player_hands[to_hand]}"
        [[player_hands, opponent_hands], description1, description2]
      end
    end
  end
  result
end


# All possible moves for any turn, some of which might not be legal
# given the state of the hands.
Moves = generate_claps + generate_touches


# Picks the best possible move that can be determined using no more
# than levels levels of recursion.  To speed this up, if the current
# state is stored in the Memo with the same or fewer levels, then
# that's used rather than recalculation.  This returns an array
# containing the score of the best move, the move, a long description
# of the move, and an abbreviated description of the move.  If a move
# guaranteeing a win can be done, then that will be chosen.  If there
# are multiple such moves, then the one that leads to a win most
# quickly is chosen.  If a win can't be chosen but a draw can be, then
# it is.  If a guaranteed lost must be chosen (assuming the opponent
# plays a perfect game), then the lose taking the most moves is chosen
# to increase the opportunities the opponent will make a mistake, and
# either a draw or win can be achieved.
def pick_move(state, levels = Levels)
  return [state.score, nil, nil, nil] if levels <= 0 || state.game_over?

  memoed_move = Memo[state]
  if memoed_move && memoed_move[0] >= levels
    # use memoed values if levels used meets or exceeds my levels
    best_move = memoed_move[1]
    best_score = memoed_move[2]
  else
    # otherwise, calculate values recursively
    best_score = nil
    best_move = nil

    # try each of the possible moves on this state and generate an
    # array of the results of those choices
    move_choices = Moves.map do |move|
      begin
        # determine the new state if the chosen move is applied
        new_state, description1, description2 = *state.do_turn(move)

        # recursively determine the score for this move (i.e., this
        # state); negate the score returned since it's in terms of
        # opponent (i.e., a win for them is a loss for us)
        score = -pick_move(new_state, levels - 1)[0]

        # increment score (by shifting away from zero) in order to be
        # able to treat is as a count of the number of moves to a win
        # or a loss
        score += score / score.abs unless score.zero?

        [score, move, description1, description2]
      rescue Exception => e
        nil  # the move was ilegal
      end
    end

    # remove nils that were generated by illegal moves
    move_choices = move_choices.select { |option| option }

    # select and sort only those with positive (i.e., winning scores)
    winning_choices = move_choices.
      select { |option| option[0] > 0 }.
      sort_by { |option| option[0] }

    unless winning_choices.empty?
      # if there's a winning option, choose the one that leads to a
      # with the least number of moves
      selected = winning_choices.first
    else
      # otherwise, choose a move that leads to a tie (preferable) or a
      # loss but in the greatest number of moves (to increase
      # opponent's opportunities to make a mistake)
      move_choices = move_choices.sort_by { |option| option[0] }
      if move_choices.last[0] == 0
        selected = move_choices.last
      else
        selected = move_choices.first
      end
    end

    best_score = selected[0]
    best_move = selected[1..3]

    # store the best move determined for future use
    Memo[state] = [levels, best_move, best_score]
  end

  [best_score] + best_move
end


# Returns a string indicating win or loss depending on score.
def score_symbol(score)
  if score > 0 : '+'
  elsif score < 0 : '-'
  else ' '
  end
end


# Calculate the best move given every finger combination, and store in
# the results hash.
results = Hash.new
1.upto(4) do |left1|
  0.upto(left1) do |right1|
    key1 = "#{right1}#{left1}"
    results[key1] = Hash.new
    1.upto(4) do |left2|
      0.upto(left2) do |right2|
        state = GameState.new([[left1, right1], [left2, right2]])
        score, move, description1, description2 = *pick_move(state, 40)
        key2 = "#{right2}#{left2}"
        results[key1][key2] = score_symbol(score) + description2
      end
    end
  end
end


# display instructions
puts <<EOS
INSTRUCTIONS

If it's your turn, select the row that describes your two hands.  Then
select the column that describes your opponent's two hands.  The cell
at the intersection will tell you how to move and what to expect.

A leading "+" indicates there is a guaranteed way to win.  A leading
"-" tells you that if the opponent plays perfectly, you will lose.  If
neither of those symbols is present, then if you and your opponent
play well, neither of you will ever win.

The rest of the cell tells you what type of move to make.  A "T"
represents a touching move, telling you which finger of yours first to
user first, and which finger of the opponent to touch.  A "C"
represents a clapping move, and it tells you the finger counts should
end up with after the clap.

EOS


# display move strategy table
line1 = "    " + results.keys.sort.map { |key1| "   #{key1}" }.join
puts line1
puts line1.gsub(/\ \ \d\d/, '----')
results.keys.sort.each do |key1|
  print "#{key1}: ",
    results[key1].keys.sort.map { |key2| " #{results[key1] [key2]}" }.join,
    "\n"
end
