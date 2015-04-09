require 'sector'

module SpaceMerchant
  class Planet
    attr_reader :items, :denizens, :sector

    def initialize ( sector, name )
      @sector = sector
      @name = name
      @items = []
      @denizens = []
    end

    def == (o)
      o.name == name
    rescue NoMethodError
      false
    end

    def name
      @name.to_s
    end

    def to_s
      name
    end

    def add_item (item)
      @items << item
    end

    def add_denizen (denizen)
      @denizens << denizen
    end

    def handle_event (player)
      print_menu
      act_on_choice gets.chomp, player
    end

    private

    def print_menu
      puts
      puts "Welcome to #{@name}"
      puts @description if @description
      puts

      puts "(E)xplore"
      puts "(U)se Item"
      puts "(L)iftoff"
      puts
      puts "(Q)uit"
      puts
      puts "What will you do?"
    end

    def act_on_choice (choice, player)
      case choice
      when /l/i: liftoff player
      when /e/i: explore player
      when /u/i: use_item player
      when /q/i: throw :quit
      end
    end

    def liftoff (player)
      puts "Launching into space..."
      player[:location] = @sector
    end

    def use_item (player)
      player[:cargo] ||= Array.new
      usable_items = player[:cargo].select{ |item| item.first.respond_to? :use }
      puts
      unless usable_items.empty?
        puts "Choose an item to use (or 0 to return):"
        puts
        usable_items.each_with_index do |item, index|
          puts "(#{index + 1}) #{item}"
        end
        puts
        choice = gets.chomp
        return if choice == '0'
        item = usable_items.delete_at choice.to_i - 1
        item.first.use player
      else
        puts "You have no items that you can use."
      end
    end

    def explore (player)
      @items = @items.sort_by{|item| item.rarity}
      luck = rand
      item = @items.find { |item| item.rarity < luck }
      if item
        puts "\nYou found a #{item}!"
        puts "Analyzing #{item}..."
        if item.description
          puts item.description
        else
          puts "Your analyzers tell you nothing about this item."
        end
        puts

        puts "Take it aboard? (y/n)"
        choice = gets.chomp

        if choice =~ /y/i
          player[:cargo] ||= Array.new
          player[:cargo_space] ||= 20
          if player[:cargo].size >= player[:cargo_space]
            puts
            puts "You don't have enough space on board."
            puts "Choose a cargo to drop, or type 0 to just leave the #{item}."
            puts
            player[:cargo].each_with_index do |cargo, index|
              puts "(#{index + 1}) #{cargo.first.to_s.capitalize} (#{cargo.last})"
            end
            cargo_choice = gets.chomp

            return if cargo_choice == '0'
            player[:cargo][cargo_choice.to_i - 1] -= 1
          end
          puts
          player[:cargo] << [item, 1]
          @items = @items.reject { |i| i == item }
          puts "You obtained a #{item}."
        end
      else
        puts "You find nothing but dust."
      end
    end

  end

  class UsableItem
    attr_reader :rarity, :name, :description

    def initialize (name, description = "", rarity = 0.7, &block)
      @effect = block if block_given?
      @name = name
      @description = description
      @rarity = rarity
    end

    def use (player)
      if @effect
        @effect.call player
      else
        puts "#{name} has no effect."
      end
    end

    def to_s
      name
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  player = {:credits => 1000}
  sector = SpaceMerchant::Sector.new("NoWhere")
  here = SpaceMerchant::Planet.new(sector, "Test")
  sector.add_planet here
  omega = SpaceMerchant::UsableItem.new("Omega", "Don't push that button.  Please.", 0.9) do |player|
    planet = player[:location]
    player[:location] = planet.sector
    puts
    puts "You hear a terrible rumbling as the Vogon constructor fleet"
    puts "descends upon #{planet.name}.  You scramble to your"
    puts "ship and launch just in time to avoid becoming space dust."
    puts
    player[:location].planets.slice!(player[:location].planets.index(planet))
  end
  here.add_item omega
  loop do
    if player[:location].nil?
      if here.nil?
        puts "You blew up the planet. Why?"
        break
      else
        player[:location] = here
      end
    end

    player[:location].handle_event(player)
  end
end
