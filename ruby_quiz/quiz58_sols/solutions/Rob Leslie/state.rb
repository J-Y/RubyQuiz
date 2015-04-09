
require 'gdbm'

class KalahState < String
  attr_accessor :turn

  INFINITY = 1.0 / 0

  def initialize(board = [4, 4, 4, 4, 4, 4, 0] * 2, turn = 0)
    replace(board.map { |seeds| seeds.chr }.join(''))
    @seeds = board.inject { |sum, x| sum + x }
    @turn = turn

    @kalah_0 = (length / 2) - 1
    @kalah_1 = @kalah_0 + (length / 2)
    @game_over = 0.chr * ((length / 2) - 1)
  end

  def array
    Array.new(length) { |i| self[i] }
  end

  def inspect
    pits, half = array, length / 2
    [pits[0, half], pits[half, half], turn].inspect
  end

  def rotate!
    half = length / 2
    self.turn = 1 - turn
    replace(self[half, half] + self[0, half])
  end

  def rotate
    dup.rotate!
  end

  def side(pit)
    pit / (length / 2)
  end

  def kalah(side)
    # (side + 1) * (length / 2) - 1
    side == 0 ? @kalah_0 : @kalah_1
  end

  def opposite(pit)
    if pit == kalah(side(pit))
      (pit + length / 2) % length
    else
      length - 2 - pit
    end
  end

  def pit_range(side = turn)
    half = length / 2
    start = half * side
    start...(start + half - 1)
  end

  def possible_moves
    pit_range.select { |pit| self[pit] > 0 }
  end

  def sow!(pit)
    other_kalah = opposite(my_kalah = kalah(side(pit)))

    seeds, self[pit] = self[pit], 0
    while seeds > 0
      begin
        pit = (pit + 1) % length
      end until pit != other_kalah
      self[pit] += 1
      seeds -= 1
    end

    if pit != my_kalah && self[pit] == 1 && side(pit) == side(my_kalah)
      other = opposite(pit)
      self[my_kalah] += 1 + self[other]
      self[pit] = self[other] = 0
    end

    self.turn = side(pit == my_kalah ? my_kalah : other_kalah)

    self
  end

  def sow(pit)
    dup.sow!(pit)
  end
  alias >> sow

  def game_over?
    # (0..1).any? { |side| pit_range(side).all? { |pit| self[pit].zero? } }
    half = length / 2
    self[0, half - 1] == @game_over || self[half, half - 1] == @game_over
  end

  def score(side)
    pits = pit_range(side)
    (pits.begin..pits.end).inject(0) { |sum, pit| sum + self[pit] }
  end

  def evaluate(depth = INFINITY, side = turn,
               alpha = -INFINITY, beta = INFINITY, &block)
    thresh = @seeds / 2
    if self[kalah(side)] > thresh
      100 + self[kalah(side)] - self[kalah(1 - side)]
    elsif self[kalah(1 - side)] > thresh
      -100 - self[kalah(1 - side)] + self[kalah(side)]
    elsif game_over?
      score(side) * 100 - score(1 - side) * 100
    elsif depth <= 0 || Thread.current[:stop]
      (block_given? ? yield(self, side) : 0).to_f
    else
      possible_moves.each do |move|
        state = self >> move
        value = (state.turn == turn) ?
          state.evaluate(depth, side, alpha, beta, &block) :
          -state.evaluate(depth - 1, 1 - side, -beta, -alpha, &block)
        return beta if value >= beta
        alpha = value if value > alpha
      end
      alpha
    end
  end
end

class CachingKalahState < KalahState
  @@cache = Hash.new do |cache, depth|
    cache[depth] = KalahCache.new(depth)
  end

  def evaluate(depth = INFINITY, side = turn,
               alpha = -INFINITY, beta = INFINITY, &block)
    if depth > 0
      cache = @@cache[depth]
      key = (side == 0 ? self : self.rotate) + "/#{alpha}/#{beta}"
      value = cache[key]
      return side == 0 ? value : -value if value
    end

    value = super

    if depth > 0
      cache[key] = side == 0 ? value : -value
    end

    value
  end
end

class KalahCache
  def initialize(depth)
    @gdbm = GDBM.new("cache-#{depth}")
  end

  def self.encode(value)
    case value
    when KalahState::INFINITY
      '+'
    when -KalahState::INFINITY
      '-'
    else
      value.to_s
    end
  end

  def self.decode(str)
    case str
    when nil
      nil
    when '+'
      KalahState::INFINITY
    when '-'
      -KalahState::INFINITY
    when /\./
      str.to_f
    else
      str.to_i
    end
  end

  def [](state)
    KalahCache.decode(@gdbm[state])
  end

  def []=(state, value)
    @gdbm[state] = KalahCache.encode(value)
  end

  def dump
    @gdbm.each_pair do |state, value|
      board = KalahState.new(Array.new(state.length) { |i| state[i] }, 0)
      puts "#{board.inspect} => #{KalahCache.decode(value)}"
    end
  end
end
