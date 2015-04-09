# Models and solves the problem of finding "magic squares" as a CSP.
# See http://en.wikipedia.org/wiki/Magic_square

require 'ai/csp'
include AI::CSP

def add_sum_constraint(problem, vars, goal_sum)
    problem.add_constraint(*vars) { |*values|
        sum = values.inject(0) {|a,b| a+b}
        goal_sum == sum
    }
end

def problem(n)
    # One variable for each square.
    domain = (1..(n*n))
    variables = (0...(n*n)).collect {|i| Variable.new(i, domain)}
    problem = Problem.new(variables)

    # Use constraint to ensure each number only appears once.
    problem.add_constraint(AllDifferent.new(*variables))

    goal_sum = n*((n**2)+1)/2

    # Use constraints to ensure that each row sums to the goal.
    0.step(n*n-1, n) {|i|
        vars = variables[i...(i+n)]
        add_sum_constraint(problem, vars, goal_sum)
    }

    # Similarly for each column.
    (0...n).each {|i|
        vars = []
        i.step(n*n-1,n) { |j|
            vars << variables[j]
        }
        add_sum_constraint(problem,vars,goal_sum)
    }
    
    # And the two diagonals.
    vars = []
    0.step(n*n-1, n+1) {|i|
        vars << variables[i]
    }
    add_sum_constraint(problem, vars, goal_sum)
    
    vars = []
    (n-1).step(n*n-n, n-1) {|i|
        vars << variables[i]
    }
    add_sum_constraint(problem, vars, goal_sum)

    problem
end

n = 3
solver = Backtracking.new(true, FAIL_FIRST)
solver.each_solution(problem(n)) {|solution|
    solution.variables.each_with_index {|variable, i|
        puts if i%n == 0
        print variable.value, " "
    }
    puts
}

puts solver
