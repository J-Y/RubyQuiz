require 'optparse'

class Player

  attr_accessor :game

  def move
  end

  def game_finished( result )
  end

  def load
  end

  def save
  end

end


class RandomPlayer < Player

  def move
    @game.board.valid_moves[rand(@game.board.valid_moves.size)]
  end

end


class HumanPlayer < Player

  def move
    (0..2).each {|i| puts @game.board[i*3, 3] }
    puts "Valid moves: #{@game.board.valid_moves.join(',')}"
    STDIN.gets.to_i
  end

end


class AIPlayer < Player

  def initialize
    @filename = "aittt.stats"
    @scores = Hash.new( 0 )
    @cur_states = []
  end

  def load
    @scores = Marshal.load( File.open( @filename ) ) if File.exist?( @filename)
  end

  def save
    File.open( @filename, 'w+') {|f| Marshal.dump( @scores, f ) }
  end

  def move
    valid_states = @game.valid_states( self )
    highest_priority = @scores[valid_states[0]]
    valid_states.each {|s| highest_priority = @scores[s] if @scores[s] > highest_priority }
    states = valid_states.find_all {|s| @scores[s] == highest_priority }
    result = states[rand(states.length)]
    @cur_states << result
    @game.board.get_move_to( result )
  end


  def game_finished( result )
    score = case result
            when :won then 100
            when :lost then -1000
            end

    if result == :lost || result ==:won
      @cur_states.each do |o|
        @scores[o] += score
        score *= 2
      end
    end
    @cur_states = []
  end

end

class Board < String

  FIELD_EMPTY = ?-

  def initialize( size )
    super( FIELD_EMPTY.chr * size )
  end

  def each( &block )
    each_byte( &block )
  end

  def valid_moves
    memo = []
    self.each_with_index {|o,i| memo << i if o == FIELD_EMPTY }
    memo
  end

  def get_move_to( new_board )
    self.each_with_index {|o,i| return i if self[i] != new_board[i]}
  end

end

class TicTacToe

  attr_accessor :board
  attr_accessor :players

  def initialize( playerO, playerX )
    @players = [playerO, playerX].each {|p| p.game = self}
    init
  end

  def init
    @board = Board.new( 9 )
  end

  def play
    cur_player = 0
    game_finished = false
    while !game_finished && !board_full?
      field = @players[cur_player].move
      if @board[field] == Board::FIELD_EMPTY
        @board[field] = cur_player.to_s
        game_finished = player_won?( cur_player.to_s[0] )
        cur_player = 1 - cur_player unless game_finished
      end
    end
    if game_finished
      @players[cur_player].game_finished(:won)
      @players[1 - cur_player].game_finished(:lost)
    else
      @players[0].game_finished(:draw)
      @players[1].game_finished(:draw)
      cur_player = 2
    end
    cur_player
  end

  def valid_states( player )
    @board.valid_moves.collect {|m| b = @board.dup; b[m] = @players.index( player ).to_s; b }
  end

  private

  def board_full?
    @board.all? {|i| i != Board::FIELD_EMPTY}
  end

  def player_won?( player )
    ( @board[0] == player && @board[1] == player && @board[2] == player ) \
    || ( @board[3] == player && @board[4] == player && @board[5] == player ) \
    || ( @board[6] == player && @board[7] == player && @board[8] == player ) \
    || ( @board[0] == player && @board[3] == player && @board[6] == player ) \
    || ( @board[1] == player && @board[4] == player && @board[7] == player ) \
    || ( @board[2] == player && @board[5] == player && @board[8] == player ) \
    || ( @board[0] == player && @board[4] == player && @board[8] == player ) \
    || ( @board[2] == player && @board[4] == player && @board[6] == player )
  end

end


class UserInterface

  class SuperHash < Hash
    include OptionParser::Completion

    def ignore_case?
      true
    end

    def complete( key )
      item = nil
      catch( 'ambiguous' ) do
        item = super( key )
      end
      item.nil? ? nil : item[1]
    end

  end

  PLAYERS = SuperHash.new
  PLAYERS["Learning AI Player"] = AIPlayer
  PLAYERS["Random Move Player"] = RandomPlayer
  PLAYERS["Human Mind Player"] = HumanPlayer

  def init_game
    puts "# Welcome to TicTacToe"
    puts "# Valid players: #{PLAYERS.keys.join(', ')}"
    first = choose_player( 'first' ).new
    first.load
    second = choose_player( 'second' ).new
    second.load
    TicTacToe.new( first, second )
  end

  def play_tictactoe
	  game = init_game
	  case game.play
	  when 0 then puts "first player won"
	  when 1 then puts "second player won"
	  when 2 then puts "draw"
	  end
	  game.players.each {|p| p.save}
  end

  def statistics
    game = init_game
    puts "Accumulating data..."
    data = [0,0,0]
    num_games = 0
    Signal.trap('INT') { throw :exit }
    catch( :exit ) do
      puts "Rounds\tOne won\tTwo won\ Draws"
      while num_games < 30000
        game.init
        data[game.play] += 1
        num_games += 1
        if num_games % 100 == 0
          puts "#{num_games}\t#{data.join("\t")}"
          data = [0,0,0]
        end
      end
    end
    game.players.each {|p| p.save}
  end

  private

  def choose_player( text )
    player = nil
    begin
      print "# Choose #{text} player (enter shortest unambiguous text) : "
      player = PLAYERS.complete( gets.chomp )
    end while player.nil?
    player
  end

end

print "# One game or endless (o, e)? "
mode = gets.downcase.chomp
if mode == 'o'
  UserInterface.new.play_tictactoe
else
  UserInterface.new.statistics
end
