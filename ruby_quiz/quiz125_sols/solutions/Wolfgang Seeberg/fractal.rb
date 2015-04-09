# Usage: ruby -s fractal.rb [-depth=4] [-plotter=[/bin/gnuplot]]
# Output: coordinates of a polygon, goes directly to gnuplot
# if available, or stdout.
class Fractal
    def initialize(depth = nil, plotter = nil)
        @depth = (depth || 3).to_i
        plotter ||= "/usr/bin/gnuplot"
        if test(?x, plotter)
            @plotter = IO.popen(plotter, "w")
            @plotter.printf "set size ratio -1 \n plot '-' w l\n"
        else
            @plotter = STDOUT
        end
        @x = @y = @angle = 0 # coordinates & orientation of pen
        @cos = [1, 0, -1, 0] # right angle = 100% = 1
        @sin = [0, 1, 0, -1]
        @line = "L"
        @production = "L+L-L-L+L"
        #@production = "L-L+L+L-L+L-L-L+L"
    end

    def plot()
        @plotter.printf "%d %d\n", @x, @y
    end

    def execute(commands, depth)
        commands.split("").each do | cmd |
            if (cmd != @line)   # + or -
                @angle = @angle.send(cmd, 1) % 4
            elsif (depth > 0)
                execute(@production, depth - 1)
            else
                @x += @cos[@angle]
                @y += @sin[@angle]
                plot()
            end
        end
    end

    def main()
        plot()
        execute(@line, @depth)
        if @plotter != STDOUT
            @plotter.printf "e\n"
            STDERR.printf "%s", " hit <Return> to exit. "
            gets
        end
    end
end # class Fractal

Fractal.new($depth, $plotter).main()
