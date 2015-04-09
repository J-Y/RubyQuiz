
require 'state'
require 'strategies'

class Player
  attr_accessor :name
  attr_writer :game, :side

  def initialize( name )
    @name = name
  end

  def choose_move
    if @side==KalahGame::TOP
      (7..12).each { |i| return i if @game.stones_at?(i) > 0 }
    else
      (0..5).each { |i| return i if @game.stones_at?(i) > 0 }
    end
  end
end

class StandardPlayer < Player
  include BasicStrategy

  @@watch = true and $stderr.sync = true

  DEPTH = 6

  def board_class
    KalahState
  end

  def choose_move(depth = DEPTH)
    state = board_class.new(@game.board, @side == KalahGame::BOTTOM ? 0 : 1)
    best = nil
    highest = -KalahState::INFINITY

    state.possible_moves.each do |move|
      value = (state >> move).evaluate(depth, state.turn, highest,
                                       &method(:strategy))

      $stderr.print "#{move}=>#{value}... " if @@watch

      best, highest = move, value if value > highest
    end

    $stderr.puts if @@watch

    best
  end
end

class ThreadedPlayer < Player
  include BasicStrategy

  @@watch = true

  DEPTH = 7
  WAIT = 15

  def choose_move(depth = DEPTH, wait = WAIT)
    state = KalahState.new(@game.board, @side == KalahGame::BOTTOM ? 0 : 1)
    moves = state.possible_moves
    threads = []

    moves.each do |move|
      thread = Thread.new(move) do |move|
        (state >> move).evaluate(depth, state.turn, &method(:strategy))
      end

      Thread.new(thread) do |thread|
        thread[:stop] = true if thread.join(wait).nil?
      end

      threads << thread
    end

    results = threads.collect { |thread| thread.value }.zip(moves)

    $stderr.puts results.map { |r| "#{r[1]}=>#{r[0]}..." }.join(' ') if @@watch

    results.max { |a, b| a.first <=> b.first }.last
  end
end

class CachingPlayer < StandardPlayer
  def board_class
    CachingKalahState
  end
end

class RandomPlayer < Player
  def choose_move
    base = (@side == KalahGame::BOTTOM) ? 0 : 7
    begin
      move = base + rand(6)
    end until @game.stones_at?(move) > 0
    move
  end
end

class HumanPlayer < Player
  def choose_move
    print 'Enter your move choice: '
    gets.chomp.to_i
  end
end
