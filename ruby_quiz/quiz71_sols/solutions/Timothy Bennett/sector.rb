module SpaceMerchant
  class Sector
    attr_reader :links, :planets, :stations, :location

    def initialize ( name, location = nil )
      @name = name
      @location = location
      @links = []
      @planets = []
      @stations = []
    end

    def name
      @name.to_s
    end

    def to_s
      name
    end

    def add_planet ( planet )
      @planets << planet
    end

    def add_station ( station )
      @stations << station
    end

    def link ( to_sector )
      @links << to_sector
    end

    def handle_event ( player )
      player[:visited_sectors] ||= []
      player[:visited_sectors] << self unless player[:visited_sectors].find { |sector| sector == self }
      print_menu
      choice = gets.chomp
      case choice
      when /d/i: choose_station
      when /l/i: choose_planet
      when /p/i: plot_course
      when /q/i: throw(:quit)
      when /\d+/: warp player, choice
      else invalid_choice
      end
    end

    def == ( other )
      if other.class == Sector
        self.name == other.name
      elsif other.class == String
        self.name == other
      else
        false
      end
    end

    private

    def warp ( player, sector_name )
      sector_regexp = Regexp.new sector_name
      sector = Galaxy.instance.sectors.find { |sector| sector.name =~ sector_regexp }
      if sector && @links.find { |sec| sec.name =~ sector_regexp }
        player[:location] = sector
        puts "Warping to #{sector.name}..."
      elsif sector.nil?
        puts "#{sector_name} does not exist."
      else
        puts "#{sector.name} cannot be reached from here."
      end
      puts
    end

    def print_menu
      puts "#{@name}"
      puts @location if @location
      puts

      puts "Station" + (@stations.size == 1 ? '' : 's') +
        ": " + @stations.map{|stat| stat.name}.join(', ') unless @stations.empty?

      puts "Planet" + (@planets.size == 1 ? '' : 's') +
        ": " + @planets.map{|plan| plan.name}.join(', ') unless @planets.empty?
      puts "Nothing here!" if @stations.empty? && @planets.empty?
      puts

      puts "(D)ock with station" unless @stations.empty?
      puts "(L)and on planet" unless @planets.empty?
      puts "(P)lot a course"
      puts

      puts "(Q)uit game"
      puts

      puts "Or warp to nearby sector: #{@links.join(', ')}"
      puts
    end

    def invalid_choice
      puts "Please enter a valid choice."
    end

    def choose_station
      player = Player.instance
      puts "There are no stations to dock with!" if @stations.empty?
      if @stations.size == 1
        dock @stations[0], player
      else
        @stations.each_with_index do |station, index|
          puts "(#{index + 1}) #{station.name}"
        end
        puts "Enter the number of the station to dock with: "

        station_index = gets.chomp.to_i - 1
        if @stations[station_index]
          dock @stations[station_index], player
        else
          puts "Invalid station."
        end
      end
    end

    def choose_planet
      player = Player.instance
      puts "There are no planets to land on!" if @planets.empty?
      if @planets.size == 1
        land @planets[0], player
      else
        @planets.each_with_index do |planet, index|
          puts "(#{index + 1}) #{planet.name}"
        end
        puts "Enter the number of the planet to land on: "

        planet_index = gets.chomp.to_i - 1
        if @planets[planet_index]
          land @planets[planet_index], player
        else
          puts "Invalid planet."
        end
      end
    end

    def land (planet, player)
      puts "Landing on #{planet.name}..."
      player[:location] = planet
    end

    def dock (station, player)
      puts "Docking at #{station.name}..."
      player[:location] = station
    end

    def plot_course
      player = Player.instance
      galaxy = Galaxy.instance
      unknown_sectors = galaxy.sectors - player[:visited_sectors]
      reachable_sectors = galaxy.find_reachable(self, unknown_sectors)
      reachable_sectors.each do |path|
        puts "#{path.first}" + (path.first.location ? "(#{path.first.location})" : '')
      end

      puts
      puts "Enter the sector name to which you wish to travel: "
      sector_name = gets.chomp
      destination = galaxy.sectors.find { |sector| sector.name =~ Regexp.new(sector_name) }
      path = galaxy.find_path( self, destination, unknown_sectors)
      puts
      unless path.nil?
        puts "Your course:"
        path.each do |sector|
          puts "#{sector}" + (sector.location ? "(#{sector.location})" : '')
        end

        puts "Confirm course (y/n)?"
        confirm = gets.chomp =~ /y/i

        if confirm
          player[:location] = destination
          puts "Traveling to #{destination}..."
        end
      else
        puts "That sector can not be reached."
      end
    end
  end
end
