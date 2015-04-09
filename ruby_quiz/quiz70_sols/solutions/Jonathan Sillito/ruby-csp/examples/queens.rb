# Models and solves the N-Queens problem as a CSP.
# See http://en.wikipedia.org/wiki/Eight_queens_puzzle

require 'ai/csp'
include AI::CSP

def problem(n)

    # variables are columns and values are rows, so assigning 
    # the first variable the value 2 corresponds to placing a 
    # queen on the board at col 0 and row 2.

    variables = (0...n).collect {|i| 
        Variable.new(i, (0...n))
    }
    problem = Problem.new(variables)

    # None of the queens can share a row. AllDifferent is a 
    # built in constraint type.
    problem.add_constraint(AllDifferent.new(*variables))
    
    # No pair of queens can be on the same diagonal. 
    variables.each_with_index {|v1,i|
        variables[(i+1)..-1].each_with_index{ |v2,j|
            problem.add_constraint(v1, v2) { |row1,row2|
                (j+1) != (row1-row2).abs
            }
        }
    }

    problem
end

solver = Backtracking.new(true, FAIL_FIRST)
solver.each_solution(problem(8)) { |solution|
    puts solution 
}

puts solver # prints some statistics
