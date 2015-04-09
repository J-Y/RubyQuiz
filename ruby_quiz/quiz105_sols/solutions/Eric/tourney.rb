# Solution for Ruby Quiz #105
# Author: Eric I.
# December 10, 2006
# www.learnruby.com

class Numeric
  # A monkey-patched convenience method to compute the maximum of two
  # numbers.
  def max(other)
    if self >= other : self
    else other
    end
  end
end


class Integer
  # A monkey-patched method to compute the gray code of an integer. The
  # gray code has properties that make it helpful to the tournament problem.
  def gray_code
    self ^ (self >> 1)
  end
end


# A tournament is really a node in a binary tree.  The value in each
# node contains the ranking of the best ranking team contained in the
# tournament tree below.
class Tournament
  attr_reader :ranking

  def initialize(ranking)
    @ranking = ranking
  end

  # Creates a tournament with the given number of teams.
  def self.create(teams)
    # create the initial node
    head_node = Tournament.new(1)

    # insert additional nodes for each further team
    for ranking in 2..teams
      head_node.add_team(ranking)
    end

    head_node
  end

  # Adds a team with the given ranking to the tournament.  It turns out
  # that the gray code of the ranking-1 has a bit pattern that conveniently
  # helps us descend the binary tree to the appropriate place at which to
  # put the team.
  def add_team(ranking)
    add_team_help(ranking, (ranking - 1).gray_code)
  end

  # Returns the number of rounds in the tournament.  This is determined by
  # taking the max of the depths of the two sub-trees and adding one.
  def rounds
    unless @left : 0
    else 1 + (@left.rounds.max(@right.rounds))
    end
  end

  # Returns the pairs playing at a given round.  A round number of 1 is
  # the first round played and therefore the bottom-most layer of the tree.
  def round(level)
    round_help(rounds - level)
  end

  # Converts the tournament tree into a String representation.
  def to_s
    lines = []  # store the result as an array of lines initially

    # create the lowest layer of the tree representing the first round
    round(1).each do |game|
      lines << game[0].to_s.rjust(3)
      lines << "---"
      lines << "   "
      lines << "---"
      lines << game[1].to_s.rjust(3)
      lines << "   "
    end
    lines.pop # last line, which just contains blanks, is not needed

    # the rest of the text tree is made through textual operations
    # by connecting teams playing with veritcal lines, then branching
    # horizontally to the next level, and then extending those branches
    begin
      count = to_s_connect(lines)
      to_s_branch(lines)
      3.times { to_s_extend(lines) }
    end until count == 1

    header_string + lines.join("\n")
  end


  protected

  # Recursively descends the tree to place a team with a new ranking.
  # Ultimately it will create two new nodes and insert them into the
  # tree representing itself and the team to be played.  When
  # descending the three, the bits in the gray code of the ranking
  # from least-significant to most-significant indicate which branch
  # to take.
  def add_team_help(ranking, gray_code)
    if @left == nil
      # bottomed out; create two new nodes
      @left = Tournament.new(@ranking)
      @right = Tournament.new(ranking)
    elsif gray_code % 2 == 0
      # bit in gray code indicates the left branch
      @left.add_team_help(ranking, gray_code >> 1)
    else
      # bit in gray code indicates the right branch
      @right.add_team_help(ranking, gray_code >> 1)
    end
  end

  # Returns the teams playing at the given round level.  The parameter
  # is actually the desired round subtracted from the number of
  # rounds.  That way we know we're at the right level when it reaches
  # zero.  It can be the case where a given branch does not have
  # enough levels; that indicates a "bye" for a good-ranking team.
  def round_help(reverse_level)
    if @left == nil : [[@ranking, "bye"]]
    elsif reverse_level == 0 : [[@left.ranking, @right.ranking]]
    else @left.round_help(reverse_level - 1) +
        @right.round_help(reverse_level - 1)
    end
  end

  # Creates a simple pair of lines showing the round numbers; this helps
  # in the interpretation of the text-tree below.
  def header_string
    result = (1..rounds).to_a.inject("") do |collect, round|
      collect + "R#{round}".center(4)
    end
    result + "\n" + "=" * result.length + "\n"
  end

  # Creates vertical lines used to indicate a game and that connect
  # the horizontal lines that refer to teams.  The teams referred to
  # are either from the first round or that have won the previous
  # round.
  def to_s_connect(lines)
    count = 0
    connect = false
    lines.each do |line|
      if line[-1, 1] == "-"
        line << "+"
        connect = !connect
        count += 1 if connect
      elsif connect
        line << "|"
      else
        line << " "
      end
    end
    count
  end

  # From the vertical lines used to represent a game, this places a
  # horizontal line in the *middle* of it which indicates the winning
  # team.  Except for the final round, these horizontal lines will be
  # used to create a game at the next round.
  def to_s_branch(lines)
    range_began = false
    lines.each_index do |i|
      if lines[i][-1, 1] == "|"
        range_began = i unless range_began
      elsif range_began
        lines[(i + range_began - 1)/2][-1] = "+"
        range_began = false
      end
      #lines[i] << " "
    end
  end

  # Extends the horizontal lines by one character.
  def to_s_extend(lines)
    lines.each do |line|
      if line =~ /(-| \+)$/
        line << "-"
      else
        line << " "
      end
    end
  end
end


if ARGV.length != 1
  $stderr.puts "Usage: #{$0} team-count"
  exit 1
end

tournament = Tournament.create(ARGV[0].to_i)

puts tournament
