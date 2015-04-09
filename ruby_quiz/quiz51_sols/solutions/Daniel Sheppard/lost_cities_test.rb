require 'lost_cities'
require 'nano/enumerable/each_combination'

class Player
  @@players = []
  def self.inherited( subclass )
    @@players << subclass unless subclass == SocketPlayer
  end
  def self.players
    @@players
  end
end
class Game
    public :score
    attr_reader :turn
end

count = 10
count = ARGV.shift.to_i if /^\d*$/=== ARGV[0]
srand(ARGV.shift.to_i) if /^\d*$/=== ARGV[0]

ARGV.each { |file| require file } if ARGV.length > 0

RecordStruct = Struct.new( :type, :wins, :scores )
records = Hash.new { |h,k| h[k] = RecordStruct.new(k.to_s, 0, []) }

seeds = Array.new(count) { rand(1_000_000) }

play_proc = lambda do |player_classes|
    p "Playing #{player_classes.inspect}"
    seeds.each do |seed|
        players = player_classes.map do |x| 
            x = x.new 
            class << x
                alias :orig_show :show
                def show(data); orig_show (data + "\n"); end
            end
            x
        end
        srand(seed)
        game = Game.new(*players)
        until game.over?
            game.rotate_player
            #puts "#{game.turn.class} #{game.turn.hand}"
            game.play
            game.draw
        end
        scores = players.map{ |player| game.score(player.lands) }.zip(players.map {|player| player.class})
        scores = scores.sort_by { |a,b| a }
        scores.each { |a,b| records[b].scores << a }
        records[scores[-1][1]].wins += 1
    end
end

makeable_players = Player.players.select {|x| x.instance_method(:initialize).arity == 0}
if(makeable_players.size > 1)
    makeable_players.each_combination(2, &play_proc)
else
    makeable_players.map{ |x| [x,x] }.each(&play_proc)
end

puts
printf("%-30s %4s  %5s  %5s  %5s", "Class", "Wins", "Avg.", "Min.", "Max.")
puts
records.values.sort_by {|r| -r.wins}.each { |record|
    printf("%-30s %4d  %2.2f  %2.2f  %2.2f", 
        record.type, 
        record.wins, 
        record.scores.inject(0) { |s,x| s + x } /record.scores.size.to_f,
        record.scores.min,
        record.scores.max)
    puts
}