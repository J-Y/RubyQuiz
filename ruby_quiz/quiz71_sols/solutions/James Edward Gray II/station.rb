#!/usr/local/bin/ruby -w

begin
  require "highline/import"
rescue LoadError
  begin
    require "rubygems"
    require "highline/import"
  rescue LoadError
    puts "#{__FILE__} requires HighLine be installed."
    exit 1
  end
end

class Numeric
  def commify
    to_s.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*\.)/, '\1,').reverse
  end
end

module SpaceMerchant
  class Station
    Good  = Struct.new(:name, :cost)
    GOODS = [ Good.new(:plants, 0.5),
              Good.new(:animals, 0.8),
              Good.new(:food, 1),
              Good.new(:luxuries, 1.2),
              Good.new(:medicine, 2),
              Good.new(:technology, 3) ]

    def initialize( sector, name )
      @sector, @name = sector, name
      
      @goods = GOODS.sort_by { rand }[0..2].sort_by { |good| good.cost }.
                     map { |good| good.dup }.
                     map { |g| [g, [:buy, :sell][rand(2)], rand(10_000) + 1] }
      @goods.each { |good| good.first.cost *= rand + 0.5 }
    end
    
    attr_reader :sector, :name
    
    def handle_event( player )
      player[:cargo_space] ||= 20
      player[:cargo]       ||= Array.new
      
      puts "Welcome pilot.  Come to do some trading?  What'll it be?\n\n"
      
      credits = player[:credits].commify.sub(/\.(\d+)$/) { |d| d[0..2] }
      puts "Credits:  #{credits}"
      if player[:cargo].empty?
        puts "  Cargo:  none\n\n"
      else
        cargo = player[:cargo].map do |g|
          "#{g.first.to_s.capitalize} (#{g.last})"
        end.join(", ")
        puts "  Cargo:  #{cargo}\n\n"
      end
      
      choose do |menu|
        menu.index = :none
        menu.shell = true
        menu.case  = :capitalize
      
        menu.prompt = "Make an offer or blast off?  "
      
        printf "%10s %7s %5s %6s\n", "Item".center(10), "Trade".center(7),
                                     "Price", "Amount"
        puts "---------- ------- ----- ------"
        @goods.each do |good|
          if good.include? :buy
            menu.choice( sprintf( "%-10s Buying   %1.2f",
                                  good.first.name.to_s.capitalize,
                                  good.first.cost ) ) do |good, details|
              sell_goods(
                player,
                @goods.find { |g| g.first.name == good[/\w+/].downcase.to_sym },
                details.split
              )

              puts "You unload the goods and blast off from the station..."
              player[:location] = sector
            end
          else
            menu.choice( sprintf( "%-10s Selling  %1.2f %6s",
                                  good.first.name.to_s.capitalize,
                                  good.first.cost,
                                  good.last.commify ) ) do |good, details|
              buy_goods(
                player,
                @goods.find { |g| g.first.name == good[/\w+/].downcase.to_sym },
                details.split
              )

              puts "You load up the goods and blast off from the station..."
              player[:location] = sector
            end
          end
        end
        
        menu.choice("Blast off") { player[:location] = sector }
      end
    end
    
    private
    
    def buy_goods( player, good, details )
      can_afford = [ good.last,
                     (player[:credits] * good.first.cost).to_i, 
                     player[:cargo_space] -
                     player[:cargo].inject(0) { |sum, item| item.last } ].min
      if can_afford == 0
        puts "I don't think you are in any position to be buyin'."
        return
      end

      amount = if details.first.nil? or details.first.to_i > can_afford
        ask("How much?  ", Integer) { |q| q.in = (1..can_afford) }
      else
        details.shift.to_i
      end
      
      player[:credits] -= good.first.cost * amount
      if add_on = player[:cargo].find { |g| g.first == good.first.name }
        add_on[-1] += amount
      else
        player[:cargo] << [good.first.name, amount]
      end
      
      reset_good(good, amount)
    end
    
    def sell_goods( player, good, details )
      begin
        max_sale = player[:cargo].find { |g| g.first == good.first.name }.last
      rescue
        puts "Uh, you don't have any of that to sell Mac."
        return
      end

      amount = if details.first.nil? or details.first.to_i > max_sale
        ask("How much?  ", Integer) { |q| q.in = (1..max_sale) }
      else
        details.shift.to_i
      end
      
      player[:credits] += good.first.cost * amount
      player[:cargo].find { |g| g.first == good.first.name }[-1] -= amount
      
      reset_good(good, amount)
    end
    
    def reset_good( good, amount )
      if (good[-1] -= amount) <= 0
        good[1..2] = [([:buy, :sell] - [good[1]]).first, rand(10_000) + 1]
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  player = {:credits => 1000}
  
  loop do
    if player[:location].nil?
      player[:location] = SpaceMerchant::Station.new(nil, "Test")
    end
    
    player[:location].handle_event(player)
  end
end
