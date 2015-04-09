module SpaceMerchant
    class Sector
        attr_reader :name, :region, :planets, :stations, :links

        def initialize(name, region)
            @name, @region = name, region
            @planets = []
            @stations = []
            @links = []
        end

        def link(other_sector)
            @links << other_sector
        end

        def add_planet(planet)
            @planets << planet
        end

        def add_station(station)
            @stations << station
        end

        def handle_event(player)
            @player = player
            @menu = :main_menu
            while @menu != :done
                puts '-'*60
                send @menu
            end
        end

        def main_menu
            puts "Sector #{name}"
            puts "#{@region.name}"
            puts
            if(@stations.length > 0) then
                puts "Station#{'s' if @stations.length>0}: "+@stations.map{|s|s.name}.join(', ')
            end
            if(@planets.length > 0) then
                puts "Planet#{'s' if @planets.length>0}: "+@planets.map{|p|p.name}.join(', ')
            end
            if(@links.length > 0) then
                puts "Nearby Sector#{'s' if @links.length>0}: "+@links.map{|s|s.name}.join(', ')
            end

            puts
            puts '(D)ock with station' if @stations.length > 0
            puts '(L)and on planet' if @stations.length > 0
            puts '(W)arp to nearby sector' if @links.length > 0
            puts
            puts '(S)ave game'
            puts '(Q)uit game'
            print '?'

            response = gets.chomp
            case response
            when /^d/i
                @menu = :dock
            when /^l/i
                @menu = :land
            when /^w/i
                @menu = :warp
            when /^s/i
                @menu = :save
            when /^q/i
                @menu = :quit
            else
                puts " *** INVALID CHOICE ***"
                @menu = :main_menu
            end
        end

        def warp
            result = nil
            begin
                result = choose_move(@links, 'sector to warp to')
            end until result != :bad
            puts "Warping..." if result != :main_menu
        end

        def dock
            result = nil
            begin
                result = choose_move(@stations, 'station to dock with')
            end until result != :bad
            puts "Docking..." if result != :main_menu
        end

        def land
            result = nil
            begin
                result = choose_move(@planets, 'planet to land on')
            end until result != :bad
            puts "Landing..." if result != :main_menu
        end

        def choose_move choices, string
            if choices.length < 1 then
                puts "There is no #{string}"
                return @menu = :main_menu
            end
            puts "Choose #{string}:"
            puts
            choices.each_with_index do |c,index|
                puts "  #{index}: #{c.name}"
            end
            puts
            puts "(M)ain menu"
            print "?"

            response = gets.chomp
            choice = response.to_i
            if response =~ /^m/i then
                return @menu = :main_menu
            elsif choice.to_s != response || choice >= choices.length then
                puts " *** INVALID CHOICE ***"
                return :bad
            else
                @player[:location] = choices[choice]
                return @menu = :done
            end
        end

        def save
            @menu = :main_menu
            filename = @player[:name]+".save"
            if(File.exists? filename) then
                puts "Do you want to overwrite previous saved game?"
                if gets.chomp !~ /^y/i
                    puts "Game not saved"
                    return
                end
            end
            File.open(filename, 'wb') do |f|
                Marshal.dump(@player, f)
            end
            puts "Game Saved."
        end

        def quit
            puts "Are you sure you want to quit? (y/n)"
            y_or_n = gets.chomp
            case y_or_n
            when /^y/i
                puts 'goodbye!'
                exit 0
            when /^n/i
                @menu = :main_menu
            else
                puts "Hmm... I'll assume you don't want to quit from that."
                @menu = :main_menu
            end
        end
    end
end


if __FILE__ == $0
    Named = Struct.new(:name)
    region = Named.new('The Region')
    s = SpaceMerchant::Sector.new('Test Sector', region)
    5.times do |i|
        s.add_planet(Named.new("planet #{i}"))
        s.add_station(Named.new("station #{i}"))
        s.link(SpaceMerchant::Sector.new("#{i}", region))
    end

    player = {:name => "test"}
    s.handle_event(player)
    p player
end
