#######################################################

# A simple 2D array, the width and height are immutable once it is created.
# #to_s accepts an optional block that can format the elements.
class Array2D
        attr_reader :w, :h
        def initialize(w, h, defel=nil)
                @w, @h=w, h
                @array=Array.new(w*h, defel)
        end
        def [](x, y)
                @array[(y%h)*w+(x%w)]
        end
        def []=(x, y, v)
                @array[(y%h)*w+(x%w)]=v
        end

        def to_s
                (0...h).collect { |y|
                        (0...w).collect { |x|
                                v=self[x, y]
                                block_given? ? yield(v) : v
                        }.join " "
                }.join "\n"
        end
end


class TrominoTiler
        def initialize(n)
                n=[1, n].max
                # initialize the working array

                @a=Array2D.new(1 << n, 1 << n)
        end

        def tile_with_empty(x, y)
                @tilenum=0 # counter
                tile_recursive(0, @a.w, 0, @a.h, x, y)
                @a
        end

        private

        # tiles the area of @a determined by xb,xe and yb,ye (b is begin, e is
        # end, so xb,xe is like the range xb...xe) with trominos, leaving
        # empty_x,empty_y empty
        def tile_recursive(xb, xe, yb, ye, empty_x, empty_y)
                half=(xe-xb)/2
                if half==1
                        # easy, just one tromino
                        @tilenum+=1
                        # set all 4 squares, empty is fixed below
                        @a[xb  , yb  ]=@tilenum
                        @a[xb+1, yb  ]=@tilenum
                        @a[xb  , yb+1]=@tilenum
                        @a[xb+1, yb+1]=@tilenum
                else
                        # tile recursive
                        mytile=(@tilenum+=1)
                        # where to split the ranges
                        xh, yh=xb+half, yb+half
                        [ # the 4 sub parts:
                        [xb, xh, yb, yh, xh-1, yh-1],
                        [xh, xe, yb, yh, xh  , yh-1],
                        [xb, xh, yh, ye, xh-1, yh  ],
                        [xh, xe, yh, ye, xh  , yh  ]
                        ].each { |args|
                                # if empty_x,empty_y is in this part, we have
                                # to adjust the last two arguments
                                if (args[0]...args[1]).member?(empty_x) &&
                                   (args[2]...args[3]).member?(empty_y)
                                        args[4]=empty_x
                                        args[5]=empty_y
                                end
                                tile_recursive(*args)
                                @a[args[4], args[5]]=mytile
                        }

                end
                # fix empty square
                @a[empty_x, empty_y]=nil
        end
end


if $0 == __FILE__
        n=(ARGV[0] || 3).to_i
        d=1 << n
        maxw=((d*d-1)/3).to_s.size
        tiler=TrominoTiler.new(n)
        # show solutions for all possible empty squares
        d.times { |y|
                d.times { |x|
                        puts tiler.tile_with_empty(x, y).to_s { |v|
                                v.to_s.rjust(maxw)
                        }, ""
                }
        }
end
