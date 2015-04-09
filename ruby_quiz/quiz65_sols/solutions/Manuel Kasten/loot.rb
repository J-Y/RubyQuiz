class SplitIt
  def initialize pirates, treasure
    @pirates = pirates
    @treasure = treasure
    @bags = []
    (0...@pirates).each{ |pirate| @bags[pirate] = [[], 0] }
    loot = @treasure.inject(0){ |res, gem| res + gem }
    done unless loot % @pirates == 0
    @share = loot/@pirates
  end
  def go
    done if @treasure.length == 0
    gem = @treasure.pop
    (0...@pirates).each do |pirate|
      if @bags[pirate][1] + gem <= @share
        @bags[pirate][1] += gem
        @bags[pirate][0].push gem
        go
        @bags[pirate][0].pop
        @bags[pirate][1] -= gem
        # it doesn't matter which pirate is which,
        # as long as their bags are empty
        break if @bags[pirate][1] == 0
      end
    end
    @treasure.push gem
  end
  def done
    puts
    if (@treasure.length == 0)
      @bags.each_with_index do |bag, pirate|
        puts "#{pirate+1}: #{bag[0].sort.inspect}"
      end
    else
      puts "The #{@pirates} pirates won't be able to " +
           "split their loot fairly. Take cover!"
    end
    exit
  end
end

if $0 == __FILE__
  pirates = ARGV.shift.to_i
  treasure = ARGV.map{ |gem| gem.to_i }.sort
  si = SplitIt.new(pirates, treasure)
  si.go
  si.done
end
