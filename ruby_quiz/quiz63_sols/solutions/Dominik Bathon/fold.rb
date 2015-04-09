# A simple 2D array, the width and height are immutable once it is created.
class Array2D
    attr_reader :w, :h
    def initialize(w, h, init_array = nil)
        @w, @h=w, h
        @array = init_array || []
    end
    def [](x, y)
        @array[(y%h)*w+(x%w)]
    end
    def []=(x, y, v)
        @array[(y%h)*w+(x%w)]=v
    end
end

class GridFold
    attr_reader :grid

    # the initial grid will be (2**n)x(2**n)
    def initialize(n = 4)
        d = 1 << n
        @grid = Array2D.new(d, d, (1..(d*d)).map { |i| [i] })
    end

    def fold_t
        fold_help(@grid.w, @grid.h / 2) { |x, y, _, nh|
            @grid[x, nh-1-y].reverse + @grid[x, nh+y]
        }
    end
    def fold_b
        fold_help(@grid.w, @grid.h / 2) { |x, y, _, _|
            @grid[x, @grid.h-1-y].reverse + @grid[x, y]
        }
    end
    def fold_l
        fold_help(@grid.w / 2, @grid.h) { |x, y, nw, _|
            @grid[nw-1-x, y].reverse + @grid[nw+x, y]
        }
    end
    def fold_r
        fold_help(@grid.w / 2, @grid.h) { |x, y, _, _|
            @grid[@grid.w-1-x, y].reverse + @grid[x, y]
        }
    end

    def self.fold(folds_str)
        folds = folds_str.to_s.downcase
        n = folds.size / 2
        unless folds =~ /\A[tblr]*\z/ && folds.size == n * 2
            raise "invalid argument"
        end
        gf = self.new(n)
        folds.scan(/./) { |f| gf.send("fold_#{f}") }
        gf.grid[0, 0]
    end

    private

    def fold_help(new_width, new_height)
        raise "impossible" unless new_width >= 1 && new_height >= 1
        new_grid = Array2D.new(new_width, new_height)
        new_width.times { |x| new_height.times { |y|
            new_grid[x, y] = yield x, y, new_width, new_height
        } }
        @grid = new_grid
        self
    end
end

if $0 == __FILE__
    begin
        p GridFold.fold(ARGV.shift.to_s)
    rescue => e
        warn e
        exit 1
    end
end
