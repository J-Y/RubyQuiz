require 'lost_cities'
require 'rule_player'
require 'yaml'
require 'nano/enumerable/each_combination'

class Game
    public :score
    attr_reader :turn
end

RecordStruct = Struct.new( :multipliers, :wins, :scores, :broken )

class Breeder
    attr_reader :multipliers, :rule_classes
    def initialize(multipliers=[[]], rule_names=[])
        @rule_classes = rule_names
        @multipliers = multipliers
        #@multipliers = Array.new(10) { @rule_classes.collect { rand - 0.5 }} unless @multipliers
        #~ rules = @rule_classes.collect { |x| x.new }
        #~ @multipliers = multipliers
        #~ @multipliers = Array.new(rules.size) {rand-0.5} unless(@multipliers)
        #~ @multipliers << 0 until @multipliers.size === rules.size
        #~ p *@rules
    end
    def breed()
        check_new_rules();
        sort();
        evolve();
    end
    def evolve()
        #keep the best 7
        @multipliers = @multipliers[0..7]
        #average the best two players
        new_player = @multipliers[0].zip(@multipliers[1]).collect { |x| 
            if x[0] || x[1]
                ((x[0]||0) + (x[1]||0))/2 
            else
                nil
            end
        }
        @multipliers << new_player
        #add 2 players with random mutation of the best player
        2.times {
            @multipliers << @multipliers[0].collect {|x| (x || 0) + (0.1*rand) - 0.05}
        }
        #add 2 players with random mutation of the new player
        2.times {
            @multipliers << new_player.collect {|x| (x || 0) + (0.1*rand) - 0.05}
        }
        #add a random player
        @multipliers << @rule_classes.collect { rand - 0.2 }
    end
    def check_new_rules()
        all_rules = Rules::BasicRule.all_rules.collect { |x| x.to_s }
        new_rules = all_rules.reject { |x| @rule_classes.include?(x) }
        @rule_classes.concat(new_rules)
        @multipliers.each {|x|
            x << nil while x.size < @rule_classes.size
        }
        new_rules.each { |x|
            new_players = [@multipliers[0].dup, Array.new(@rule_classes.size)]
            new_players.each { |a|
                a[@rule_classes.index(x)] = 0.8
            }
            @multipliers.concat(new_players)
        }
    end
    def sort();
        records = play_games(5)
        new_multipliers = records.values.sort_by{|r| [-r.broken, r.wins, r.scores.inject(0){|a,b|a+b}]}.collect { |r| r.multipliers}.reverse
        new_multipliers.each_with_index { |x,i|
            puts "#{i} was #{@multipliers.index(x)}"
            $stdout.flush
        }
        @multipliers = new_multipliers
    end
    def play_games(game_count)
        records = Hash.new { |h,k| h[k] = RecordStruct.new(k, 0, [],0) }
        seeds = Array.new(game_count) { rand(1_000_000) }
        @multipliers.each_combination(2) do |multipliers|
            seeds.each do |seed|
                players = multipliers.collect { |x| MultiplierPlayer.new(@rule_classes, x) }
                players.each do |x| 
                    class << x
                        alias :orig_show :show
                        def show(data); orig_show (data + "\n"); end
                    end
                end
                srand(seed)
                game = Game.new(*players)
                300.times do
                    game.rotate_player
                    #~ puts "#{game.turn.class} #{game.turn.hand}"
                    game.play
                    game.draw
                    break if game.over?
                end
                if game.over?
                    scores = players.map{ |player| [game.score(player.lands), player] }
                    scores = scores.sort_by { |a,b| a }
                    scores.each { |a,b| records[b.multipliers].scores << a }
                    records[scores[-1][1].multipliers].wins += 1
                else
                    players.each { |p|
                        records[p.multipliers].broken += 1
                    }
                end
            end
        end
        records
    end
end

if File.exist?('data2.yaml')
    breeder_args = File.open('data2.yaml','r') { |f| YAML::load(f) } 
    breeder = Breeder.new(*breeder_args)
    File.open('data2.yaml.bak','w') { |f| 
        YAML::dump([breeder.multipliers, breeder.rule_classes], f) 
    }
else
    breeder = Breeder.new
end
while true
    original_best = breeder.multipliers[0]
    breeder.breed
    breeder.rule_classes.zip(breeder.multipliers[0]).each { |a,b|
        printf("%-40s %4.4f",a,b)
        puts
    }
    unless breeder.multipliers[0] === original_best
        p "Best Player has changed" 
    end
    File.open('data2.yaml','w') { |f| 
        YAML::dump([breeder.multipliers, breeder.rule_classes], f) 
    }
end