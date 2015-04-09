# Models and solves the Golomb Ruler problem as a CSP. 
# See http://en.wikipedia.org/wiki/Golomb_ruler

require 'ai/csp'
include AI::CSP

def pairs(variables)
    result = []
    variables.each_with_index {|v1, i|
        variables[(i+1)..-1].each {|v2|
            result << [v1,v2]
        }
    }
    result
end

def problem(marks, length)
    domain = (0...length)
    variables = (0...marks).collect {|mark| Variable.new(mark, domain)}
    problem = Problem.new(variables)

    # Add constraints that ensure that no distinct pairs have the same
    # distance between them.
    all_pairs = pairs(variables)
    all_pairs.each {|pair1|
        all_pairs.each {|pair2|
            next if pair1 == pair2
            problem.add_constraint(*(pair1 + pair2)) {|a,b,c,d|
                (a-b).abs != (c-d).abs
            }
        }
    }

    problem
end

solver = Backtracking.new(true, FAIL_FIRST)

# For a given number of marks find the first length that will work, I
# guess this doesn't need to be sequential but ok for our purposes ...
marks = 5
length = marks*2 # reasonable starting point?
solution = nil
aggregate_time = 0
while !solution do
    puts "Trying length=#{length}"
    solution = solver.first_solution(problem(marks,length))
    length += 1
    aggregate_time += solver.time
end

puts solution
puts solver
puts "total time = #{aggregate_time}"

