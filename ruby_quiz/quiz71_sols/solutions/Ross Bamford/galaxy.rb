require 'singleton'

unless $0 == __FILE__
  require 'sector'
  require 'planet'
  require 'station'
end

# The implementation of Dijkstra's shortest path algorithm I use for 
# find_path and find_reachable was lifted directly from Dominik Bathon's
# solution to quiz 31 (thanks!) and only modified very slightly to suit 
# our purpose. This Hash modification comes with that.
class Hash #:nodoc: all
  # find the key for with the smallest value, delete it and return it
  def delete_min_value
    return nil if empty?
    minkey=min=nil
    each { |k, v|
      min, minkey=v, k if !min || v<min
    }
    delete(minkey)
    minkey
  end
end

module SpaceMerchant #:nodoc:
  # ==== Galaxy for Ruby Quiz 71.
  #
  # ===== Requires:
  # * Sector.new(name, location = nil)
  # * Sector#link(to_sector)
  # * Sector#links => [Sector:1, ..., Sector:N]
  # * Sector#planets => [Planet:1, ..., Planet:N]
  # * Sector#stations => [Station:1, ..., Station:N]
  # * Sector#add_planet(planet)
  # * Sector#add_station(station)
  #   
  # * Planet.new(name, location = nil)
  # * Station.new(name, location = nil)
  #
  # * All classes need #name => String
  # * All classes should define == in terms of name *at* *least*
  #   
  # ===== Extra features:
  # * Simplistic galaxy generation
  # * Galaxy codes allow whole galaxy to be regenerated
  # * Support for long-distance route availablility by distance
  # * Compatible with Jacob Fugal's GalaxyLoader
  # * Able to dump galaxies in GalaxyLoader format
  #   
  class Galaxy
    include Singleton

    # internal stuff
    TRUEBLOCK = lambda { true }   #:nodoc:
    ATOZ = ('A'..'Z').to_a        #:nodoc:
    
    class << self
      # tired of writing 'Galaxy.instance' in tests...
      def method_missing(sym, *args, &blk) #:nodoc: 
        instance.send(sym, *args, &blk)
      end
    end

    # This WeakHash implementation is by Mauricio Fernandez. I
    # just added support for a default, and full key reclaimation
    # to suit our need to have the default block run as and when 
    # (but only when) necessary.
    # 
    # See: http://eigenclass.org/hiki.rb?weakhash+and+weakref 
    class WeakHash #:nodoc: all
      attr_reader :cache
      def initialize( cache = Hash.new, &initializer )
        @cache = cache
        @initializer = initializer
        @key_map = {}
        @rev_cache = Hash.new{|h,k| h[k] = {}}
        @reclaim_value = lambda do |value_id|
          if @rev_cache.has_key? value_id
            @rev_cache[value_id].each_key{|key| @cache.delete key}
            @rev_cache.delete value_id
          end
        end
        @reclaim_key = lambda do |key_id|
          if @key_map.has_key? key_id
            @cache.delete @key_map[key_id]
            @key_map.delete key_id
          end
        end
      end

      def []( key )
        value_id = @cache[key]

        if value_id.nil? && @initializer
          self[key] = @initializer.call(self, key)
          value_id = @cache[key]
        end
        
        return ObjectSpace._id2ref(value_id) unless value_id.nil?
        nil
      end

      def []=( key, value )
        case key
        when Fixnum, Symbol, true, false
          key2 = key
        else
          key2 = key.dup
        end
        @rev_cache[value.object_id][key2] = true
        @cache[key2] = value.object_id
        @key_map[key.object_id] = key2

        ObjectSpace.define_finalizer(value, @reclaim_value)
        ObjectSpace.define_finalizer(key, @reclaim_key)
      end
    end
      
    attr_reader :sectors, :code
    
    def initialize #:nodoc:
      @sectors = []

      @pathcache = WeakHash.new do |h, key|
        start, avoid = key
        h[key] = build_prev_hash(start, avoid)
      end

      @code = nil
    end

    # Change the code for the galaxy. This will cause the
    # whole galaxy to be regenerated, from the specified code,
    # with the current galaxy lost, so be careful.
    #
    # Pretty much equivalent to +generate+
    def code=(code)
      generate(code)
    end

    # Add a sector.
    def add_sector(sector)
      sectors << sector
    end

    # Get the starting location for this galaxy. If a galaxy
    # hasn't been generated (or loaded), this will have a
    # random one generated.
    def starting_location
      generate if @sectors.empty?
      sectors.first
    end

    # select sectors with the supplied block
    def find_sectors(&blk)
      sectors.select(&(blk || TRUEBLOCK)) || []
    end

    # select stations with the supplied block
    def find_stations(&blk)
      sectors.inject([]) do |a, e|
        a.push(*e.stations.select(&(blk || TRUEBLOCK)))
      end
    end

    # select planets with the supplied block
    def find_planets(&blk)
      sectors.inject([]) do |a, e|
        a.push(*e.planets.select(&(blk || TRUEBLOCK)))
      end
    end

    # find the shortest path between start and finish (sectors).
    # Optionally supply an array of sectors to avoid. Returns
    # an array of sectors or nil if no path can be found.
    def find_path(start, finish, *avoid_sectors)
      shortest_path(start, finish, avoid_sectors.flatten)
    end

    # find all sectors reachable from start, optionally avoiding
    # specified sectors, and imposing a maximum journey 'cost'
    # (in terms of number of steps from start).
    def find_reachable(start, avoid_sectors = nil, maxcost = nil)
      all_paths(start,avoid_sectors,maxcost)
    end

    # Generation is very simple, basically making up a tangled
    # mess of randomly connected sectors. You can pass in a code
    # that specifies some parameters used for the generator, 
    # allowing the same galaxy to be generated again by supplying
    # the same code.
    #
    # You should call this manually before using the galaxy, or
    # let +starting_location+ handle that for you if you don't
    # want to load a galaxy or anything.
    #
    # Returns the new galaxy code.
    def generate(code = nil)
      # bit odd but gives us a good seed - one call to randomize,
      # one to get the value of that previous random seed, and
      # then set to that.      
      size, max_links, max_planets, seed = 
            decode(code) || [(500 + rand(500)), 5, 5, srand && srand]
   
      clear 
      srand(seed)      
      @sectors = gen_bodies(max_planets, gen_sectors(size, max_links))

      # seed rand again, don't want to affect rand in game
      srand     
      @code = encode(size, max_links, max_planets, seed)
    end

    # Vape the galaxy, clears everything.
    def clear
      initialize
    end
        
    # Dump this galaxy to a string in the same format as used by 
    # Jacob Fugal's GalaxyLoader. 
    def dump
      locs = sectors.inject({}) { |h,s| (h[s.location || nil] ||= []) << s; h }

      dump = "galaxy {\n"
      locs.each do |loc, sectors|
        dump << "  region(#{loc.inspect}) {\n" if loc
        sectors.each do |sector|
          dump << "    sector(#{SpaceMerchant::Galaxy.sectors.index(sector) + 1}) {\n"
          sector.planets.each do |planet|
            dump << "      planet #{planet.name.inspect}\n"
          end
          sector.stations.each do |station|
            dump << "      station #{station.name.inspect}\n"
          end
          unless sector.links.empty?
            dump << "      neighbors "
            dump << sector.links.map { |s| Galaxy.sectors.index(s) + 1 }.join(', ')
            dump << "\n"
          end
          dump << "    }\n"
        end
        dump << "  }\n" if loc
      end
      dump << "}\n"
    end

    alias :to_a :sectors

    private

    # these handle the galaxy codes
    def decode(code)
      if code =~ /^(\d{4})(\d)(\d)([\da-fA-F]+)$/
        [$1.to_i, $2.to_i, $3.to_i, $4.hex]
      end
    end

    def encode(size, max_links, max_planets, seed)
      size.to_s.rjust(4,'0') << 
        max_links.to_s[0,1] << 
        max_planets.to_s[0,1] << 
        sprintf('%x',seed)
    end

    # This whole generation bit is currently sloppy and slow 
    def gen_sectors(size, max_links)        
      sectors = (0...size).map { |i| Sector.new(i.to_s) }
      avail = sectors.dup
      
      sectors.each do |sector|
        rand(max_links).times do
          to = avail[rand(avail.length)]
          sector.link(to)
          to.link(sector)
          avail.delete(to) if to.links.length >= max_links
        end
      end

      unlinked = sectors.select { |e| e.links.empty? }

      # just makes sure the last few sectors are reachable. Gives
      # a nice varying density to space I think :)
      remain = sectors - unlinked
      until unlinked.empty?
        break unless to = remain[rand(remain.length)] # to hell with it then
        sector = unlinked.shift
        sector.link(to)
        to.link(sector)
      end

      sectors
    end

    def gen_body_name
      (0..(rand(3)+1)).inject("") { |s,i| s << ATOZ[rand(26)] } + 
        rand(5000).to_s + 
        ATOZ[rand(26)]
    end
    
    def gen_bodies(max_planets, sectors)     
      avail = sectors.dup
      ((avail.length / 3) + rand(avail.length / 2)).to_i.times do
        sect = avail.delete_at(rand(avail.length))

        station = rand > 0.5
        planets = rand(max_planets)

        sect.add_station(Station.new(sect, gen_body_name)) if station
        planets.times { sect.add_planet(Planet.new(sect, gen_body_name)) }
      end       

      sectors 
    end
    
    # returns a hash that associates each reachable (from start)
    # position p, with the previous position on the shortest path
    # from start to p and the length of that path.
    # example: if the shortest path from 0 to 2 is [0, 1, 2], then
    # prev[2]==[1, 2], prev[1]==[0, 1] and prev[0]==[nil, 0].
    # so you can get all shortest paths from start to each reachable
    # position out of the returned hash.
    # stop_at isn't taken into account here, since it's better for us
    # to build full sets we can cache for future use, rather than
    # cutting short and having a lot of less useful path sets.
    def build_prev_hash(start, avoid_sectors = nil)
      avoid_sectors ||= []
      prev={start=>[nil, 0]} # hash to be returned
    
      # positions which we have seen, but we are not yet sure about
      # the shortest path to them (the value is length of the path,
      # for delete_min_value):
    
      active={start=>0}
      until active.empty?
        # get the position with the shortest path from the
        # active list
        cur=active.delete_min_value
        newlength=prev[cur][1]+1 # path to cur length + 1
    
        # for all reachable neighbors of cur, check if we found
        # a shorter path to them
        cur.links.each { |n|
          # skip sectors we're avoiding
          next if avoid_sectors.include?(n)
          
          if old=prev[n] # was n already visited
            # if we found a longer path, ignore it
            next if newlength>=old[1]
          end
    
          # (re)add new position to active list
          active[n]=newlength
    
          # set new prev and length
          prev[n]=[cur, newlength]
        }
      end
    
      prev
    end
    
    def shortest_path(from, to, avoid_sectors)
      prev = @pathcache[[from, avoid_sectors]]

      # if prev is nil now, we know there is no path
      if prev
        if prev[to]
          # path found, build it by following the prev hash from
          # "to" to "from"
          path=[to]
          path.unshift(to) while to=prev[to][0]
          path
        else
          nil
        end
      end
    end
    
    def all_paths(start, avoid_sectors, maxcost)
      r = @pathcache[[start, avoid_sectors]]
      r = r.reject { |sector, (prev, cost)| cost > maxcost } if maxcost
      r.map { |sector, (prev, cost)| [sector, cost] }
    end
  end

  if $0 == __FILE__
    # The comparable stuff is needed only by the tests,
    # not the Galaxy impl itself.  
    class Named #:nodoc: all
      def initialize(sector, name); @name = name.to_s; end
      def name; @name; end
      alias :to_s :name
      def inspect; "#{self.class.name}:#{@name}"; end
      def ==(o); name == o.name; end
      def <=>(o); name <=> o.to_s; end
    end
    
    class Sector < Named #:nodoc: all
      def initialize(name, location = nil)
        super(nil, name)
        @location, @planets, @stations, @links = location, [], [], []
      end
      attr_accessor :location, :planets, :stations, :links
      def add_planet(planet); @planets << planet; end
      def add_station(station); @stations << station; end
      def link(o); @links << o; end
      def ==(o)
        begin
          name == o.name && 
            planets == o.planets && 
            stations == o.stations && 
            links.length == o.links.length
        rescue NoMethodError
          false
        end
      end
    end
    
    class Planet < Named #:nodoc: all
    end
    
    class Station < Named #:nodoc: all
    end
    
    if ARGV.include? '-bm'
      ##benchmark##
      require 'benchmark'

      puts "### Generate:"
      Benchmark.bm do |b|
        b.report { Galaxy.generate }
      end
      
      links = Galaxy.sectors.inject(0) { |s,e| s + e.links.length }
      puts "Galaxy has #{Galaxy.sectors.size} sectors (#{links} links)"
      
      puts "\n### Find reachable; 1 step"
      Benchmark.bm do |b|
        r = nil
        b.report { r = Galaxy.find_reachable(Galaxy.sectors[3],nil,1) }
        puts "#{r.length}/#{Galaxy.instance.sectors.length} sectors reachable"
      end
      
      puts "\n### Find reachable; 3 steps"
      Benchmark.bm do |b|
        r = nil
        b.report { r = Galaxy.find_reachable(Galaxy.sectors[3],nil,3) }
        puts "#{r.length}/#{Galaxy.instance.sectors.length} sectors reachable"
      end
      
      puts "\n### Find reachable; unlimited steps"
      Benchmark.bm do |b|
        r = nil
        b.report { r = Galaxy.find_reachable(Galaxy.sectors[3]) }
        puts "#{r.length}/#{Galaxy.instance.sectors.length} sectors reachable"
      end
      
      puts "\n### Find reachable; 3 steps, avoid #2"
      Benchmark.bm do |b|
        r = nil
        b.report { r = Galaxy.find_reachable(Galaxy.sectors[3],[Galaxy.sectors[2]], 3) }
        puts "#{r.length}/#{Galaxy.instance.sectors.length} sectors reachable"
      end
      
      puts "\n### Find reachable; unlimited steps, avoid #2"
      Benchmark.bm do |b|
        r = nil
        b.report { r = Galaxy.find_reachable(Galaxy.sectors[3],[Galaxy.sectors[2]]) }
        puts "#{r.length}/#{Galaxy.instance.sectors.length} sectors reachable"
      end
      
      puts "\n### Find path sect[3] to sect[-1]"
      Benchmark.bm do |b|
        sect = Galaxy.sectors
        b.report { Galaxy.find_path(sect[3],sect[-1]) }
      end
      
      puts "\n### Find path sect[3] to sect [-10]"
      Benchmark.bm do |b|
        sect = Galaxy.sectors
        b.report { Galaxy.find_path(sect[3],sect[-10]) }
      end
      
      puts "\n### Find path sect[1] to sect[-1]"
      Benchmark.bm do |b|
        sect = Galaxy.sectors
        b.report { Galaxy.find_path(sect[1],sect[-1]) }
      end
      
      puts "\n### Find path sect[1] to sect[-5]"
      Benchmark.bm do |b|
        sect = Galaxy.sectors
        b.report { Galaxy.find_path(sect[1],sect[-5]) }
      end
      ##benchmark##
    else
      require 'test/unit'
     
      class TestGalaxy < Test::Unit::TestCase
        def setup
          # Set up a testmodel
          @s1 = Sector.new('1')
          @s2 = Sector.new('2')
          @s3 = Sector.new('3')
          @s4 = Sector.new('4')
          @s5 = Sector.new('5')
          @s6 = Sector.new('6')
          @s7 = Sector.new('7')
          @s8 = Sector.new('8')
          
          @s1.links = [@s3]
          @s2.links = [@s1, @s3, @s5]
          @s3.links = [@s2, @s6]
          @s4.links = []
          @s5.links = [@s2]
          @s6.links = [@s7]
          @s7.links = [@s5]
          @s8.links = [@s4,@s2]
          
          @s1.planets  += [@s1p1 = Planet.new(@s1,'s1p1'),
                           @s1p2 = Planet.new(@s1,'s1p2')]
          @s2.planets  += [@s2p1 = Planet.new(@s2,'s2p1'),
                           @s2p2 = Planet.new(@s2,'s2p2')]
          @s2.stations << @s2s1 = Station.new(@s2,'s2s1')
          @s3.stations << @s3s1 = Station.new(@s3,'s3s1')
              
          Galaxy.instance.instance_eval { initialize }
          Galaxy.instance.sectors << @s1 << @s2 << @s3 << @s4 << @s5 << @s6 << @s7 << @s8
        end
      
        def test_initialize
          assert_equal [], Galaxy.instance_eval { new }.sectors
        end

        def test_starting_location
          g = Galaxy.instance_eval { new }
          assert g.sectors.empty?
          r = g.starting_location
          assert !g.sectors.empty?
          assert_equal r, g.sectors[0]
        end

        def test_find_sectors
          assert_equal [], Galaxy.find_sectors { |sector| nil }
          assert_equal [@s3, @s4, @s5, @s6, @s7, @s8], 
              Galaxy.find_sectors { |sector| sector.planets.empty? }
          assert_equal [@s1, @s2], Galaxy.find_sectors { |sector| sector.planets.length == 2 }
          assert_equal Galaxy.find_sectors { true }, Galaxy.find_sectors
        end

        def test_find_planets
          assert_equal [], Galaxy.find_planets { |planet| nil }
          assert_equal [@s2p1], Galaxy.find_planets { |planet| planet.name == 's2p1' }
          assert_equal [@s2p1, @s2p2], Galaxy.find_planets { |planet| planet.name =~ /s2p./ }
          assert_equal Galaxy.find_planets { true }, Galaxy.find_planets
        end

        def test_find_stations
          assert_equal [], Galaxy.find_stations { |station| nil }
          assert_equal [@s2s1], Galaxy.find_stations { |station| station.name == 's2s1' }
          assert_equal [@s2s1, @s3s1], Galaxy.find_stations { |station| true }
          assert_equal Galaxy.find_stations { true }, Galaxy.find_stations
        end

        def test_find_path
          # no path 5 to 4
          assert_equal nil, Galaxy.find_path(@s5, @s4)
          assert_equal [@s1], Galaxy.find_path(@s1, @s1)
          assert_equal [@s1, @s3], Galaxy.find_path(@s1, @s3)
          assert_equal [@s5, @s2, @s1], Galaxy.find_path(@s5, @s1)

          # avoid sectors
          assert_equal [@s1, @s3, @s2, @s5], Galaxy.find_path(@s1, @s5)
          assert_equal [@s1, @s3, @s6, @s7, @s5], Galaxy.find_path(@s1, @s5, @s2)
          assert_equal [@s1, @s3, @s6, @s7, @s5], Galaxy.find_path(@s1, @s5, [@s2])
        end

        def test_find_reachable 
          # only s4 is reachable from s4
          assert_equal [[@s4, 0]], Galaxy.find_reachable(@s4)
          assert_equal([[@s1, 0], [@s2, 2], [@s3, 1], [@s5, 3], [@s6, 2], [@s7, 3]], 
                       Galaxy.find_reachable(@s1).sort)
          assert_equal([[@s1, 0], [@s2, 2], [@s3, 1], [@s6, 2]],
                       Galaxy.find_reachable(@s1,nil,2).sort)

          # avoiding sectors
          assert_equal([[@s1, 2], [@s2, 1], [@s3, 2],[@s4, 1],[@s5, 2], [@s6, 3], [@s7, 4], [@s8, 0]],
                       Galaxy.find_reachable(@s8).sort)
          assert_equal([[@s4, 1], [@s8, 0]],
                       Galaxy.find_reachable(@s8,[@s2],nil).sort)
        end

        def test_generate
          # no map     
          Galaxy.clear
          assert_nil Galaxy.code

          # make a map, keep the seed
          code = Galaxy.generate
          first = Galaxy.sectors.dup
          assert_equal code, Galaxy.code

          # new random map, different from first?
          assert_equal Galaxy.generate, Galaxy.code
          assert_not_equal code, Galaxy.code
          assert_not_equal first, Galaxy.sectors

          # new map with first seed, same as first?
          Galaxy.generate(code)
          assert_equal first, Galaxy.sectors

          # make sure all sectors can be reached
          assert_equal Galaxy.sectors.length, Galaxy.find_reachable(Galaxy.sectors.first).length

          # make sure we actually got some planets etc.
          assert !Galaxy.find_planets.empty?
          assert !Galaxy.find_stations.empty?
        end

        def test_code          
          Galaxy.generate

          code = Galaxy.code
          first = Galaxy.sectors.dup

          Galaxy.code = "010033" + sprintf('%x', Time.now.to_i)

          assert_not_equal code, Galaxy.code          
          assert_not_equal first, Galaxy.sectors

          assert_equal 100, Galaxy.sectors.length

          Galaxy.code = code
          assert_equal first, Galaxy.sectors
        end

        if defined?(GalaxyLoader)
          def test_dump          
            begin
              first = Galaxy.sectors.dup

              File.open('test.glx', 'w+') do |f|
                f << Galaxy.dump 
              end

              Galaxy.generate

              assert_not_equal first, Galaxy.sectors

              Galaxy.clear
              Galaxy.load('test.glx')

              assert_equal first, Galaxy.sectors
            ensure              
              File.delete('test.glx') if File.exists?('test.glx')
            end
          end
        else
          warn "Galaxy#dump not tested (GalaxyLoader unavailable)"
        end
      end
    end
  end
end

