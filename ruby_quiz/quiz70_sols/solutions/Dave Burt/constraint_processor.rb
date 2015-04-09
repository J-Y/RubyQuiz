#!/usr/local/bin/ruby
#
# Constraint Processor
#
# A response to Ruby Quiz of the Week #70 - Constraint Processing
# [ruby-talk:183515]
#
# This library allows you to find solutions to mathematical problems by
# stating the problem rather than the steps to the solution.
#
# It's a very naive constraint processor, though, and only does exhaustive
# nested loops, so don't bother trying to solve sudokus or n-queens for n > 4
# or anything like that.
#
# The interface is nice, and you could put a real, useful constraint solver
# behind it. It's an interesting paradigm to write a program in.
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 14 Mar 2005
#
# Last modified: 14 Mar 2005
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is
#             not disallowed. Credit's appreciated if you use my code. I'd
#             appreciate seeing any modifications you make to it.
#

require 'ostruct'

begin
    require 'orderedhash'  # Get it from RAA
    class OrderedHash
        def reverse!
            @order.reverse!
            self
        end
        def reverse
            dup.reverse!
        end
    end
rescue LoadError
    class Hash
        def reverse() self end
    end
    OrderedHash = Hash
end

class ConstraintProcessor

    def initialize
        @variables = OrderedHash.new
        @constraints = []
    end
    def variable(name, domain)
        @variables[name] = domain
    end
    def constraint(&block)
        @constraints << block
    end
    def unique(*variable_names)
        constraint { variable_names.map {|name| send(name) }.uniq.size ==
                     variable_names.size }
    end
    def solve
        solutions = []
        vars = OpenStruct.new
        initial_proc = proc do
            solutions << vars.dup if \
                @constraints.all? {|c| vars.instance_eval(&c) }
        end
        @variables.reverse.inject(initial_proc) do |f, (name, domain)|
            proc do
                domain.each do |i|
                    vars.send("#{name}=", i)
                    f.call
                end
            end
        end.call
        solutions
    end
    class << self
        def constrain(&block)
            problem = ConstraintProcessor.new
            problem.instance_eval(&block)
            problem.solve
        end
    end
end
def constrain(&block)
    ConstraintProcessor.constrain(&block)
end

if $0 == __FILE__
    solution = constrain do
        variable :a, 0..9
        variable :b, 0..9
        variable :c, 0..9
        unique(:a, :b, :c)
        constraint { a + b == c }
        constraint { c % 2 == 0 }
    end
    p solution
end
