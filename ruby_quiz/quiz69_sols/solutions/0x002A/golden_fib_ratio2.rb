require 'rubygems'
require 'svg/svg'
require 'memoize'

module GoldenRectangle
        COLORS = ['red', 'green', 'blue', 'yellow']
        SEED_POS = {:x => 0, :y => 0}


        class PreSeedSquare
                def height
                        0
                end

                def x
                        SEED_POS[:x]
                end

                def y
                        SEED_POS[:y]
                end

                def color
                        COLORS[0]
                end

                def parent
                        @parent
                end
        end

        class SeedSquare < PreSeedSquare
                def initialize
                        @parent = PreSeedSquare.new
                end

                def fibo(n)
                        a, b = 1, 1
                        n.times { a, b = b, a + b}
                        a
                end

                def size
                        fibo(level)
                end

                def width
                        size
                end

                def level
                        0
                end

                alias_method :height, :width

                def color
                        COLORS[1]
                end

                def as_spiral
                        ["M#{x},#{y + height}", "A#{width},#{height} 0 0,1 #{x + width},#{y}"]
                end

                def as_squares
                        svg_square
                end

                def svg_square
                        col = self.color
                        group = SVG::Group.new
                        group.transform = "rotate(90) translate(#{-width},#{-height})"
                        group.id = level
                        group << SVG::Rect.new(0, 0, width, height) { self.style = SVG::Style.new(:fill => col, :opacity => 0.5) }

                        path = ["M#{0},#{0}", "A#{width},#{height} 0 0,0 #{width},#{height}"]
                        group << SVG::Path.new(path) {
                                self.style = SVG::Style.new(:fill => 'none', :stroke => '#000', :stroke_width => 1, :stroke_opacity => 1.0)
                        }
                        group
                end
        end

        class Square < SeedSquare
                include Memoize

                attr_reader :parent

                def initialize(parent)
                        @parent = parent
                        @grandparent = @parent.parent

                        # without memoization this implementation wouldn't be feasible
                        [:level, :parent, :color, :size].each {|f| memoize f }
                end

                class << self
                        alias_method :attach_to, :new
                end

                def as_squares
                        g1 = @parent.as_squares
                        g2 = svg_square
                        g2 << g1
                        g2
                end

                def color
                        if @grandparent.parent.nil?
                                COLORS[2]
                        elsif
                                @grandparent.parent.parent.nil?
                                COLORS[3]
                        else
                                (COLORS - [@parent.parent.parent.parent.color, @parent.parent.parent.color, @parent.color]).first
                        end
                end

                def level
                        @parent.level + 1
                end
        end
end

def fixpoint(start, limit, &blk)
        limit.times do
                start = blk.call(start)
        end
        start
end

iterations = ARGV.shift || 17

# the golden rectangle is the fixpoint of the function that attaches a
square
# to a golden-rectangle-approximation
# we start with a 1x1 seed
the_golden_rectangle = fixpoint(GoldenRectangle::SeedSquare.new,
iterations) do |rectangle|
        GoldenRectangle::Square.attach_to rectangle
end

svg = SVG.new('1024', '768', '2500 -1100 1024 768')
svg << the_golden_rectangle.as_squares
svg << SVG::Path.new(the_golden_rectangle.as_spiral) {
        self.style = SVG::Style.new(:fill => 'none', :stroke => '#000', :stroke_width => 1, :stroke_opacity => 1.0)
}
puts svg.to_s
