module Stopwatch
    class Lap
        attr_reader :name, :time
        def initialize( name )
            @name = name
            @time = Time.new
        end
    end

    def self.start
        @laps = [ ]
        self.mark :start
    end

    def self.mark( lap_name )
        lap = Lap.new( lap_name )
        if @laps.empty?
            puts "Stopwatch started at #{lap.time}"
        else
            last_lap = @laps.last
            elapsed = lap.time - last_lap.time
            puts "+#{(elapsed*10).round/10.0}s to #{lap_name}" # + " (since #{last_lap.name})"
        end
        @laps << lap
    end

    def self.time( lap_name )
        yield
        self.mark lap_name
    end

    def self.stop
        now = Time.new
        elapsed = now - @laps.first.time
        puts "Stopwatch stopped at #{now}; #{(elapsed*10).round/10.0}s elapsed"
    end
end
