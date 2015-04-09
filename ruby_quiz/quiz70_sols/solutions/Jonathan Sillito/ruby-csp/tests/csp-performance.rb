# This script creates a moderate sized CSP and solves it with 4
# variations of our chronological backtracking algorithm. The purpose
# is to test the performance of the algorithms.

require 'ai/csp'
include AI::CSP

def problem
    domain = (0...10)
    vars = (0...10).collect {|i| Variable.new(i, domain)}
    prob = Problem.new(vars)
    prob.add_constraint(0,1) {|v1,v2| v1 < v2}
    prob.add_constraint(0,3) {|v1,v3| v1 <= v3}
    prob.add_constraint(2,3,4) {|v3,v4,v5| v3+v4==v5}
    prob.add_constraint(AllDifferent.new(vars[3], vars[6], vars[9]))
    #prob.add_constraint(vars[3], vars[6], vars[9]) {|a,b,c|
    #    a != b and b != c and a != c
    #}

    prob.add_constraint(AllSame.new(vars[2],vars[7],vars[8]))
    #prob.add_constraint(vars[2],vars[7],vars[8]) {|a, b, c|
    #    a == b and b == c
    #}

    prob.add_constraint(5,6,7) {|a,b,c| a==b and b==c}
    prob.add_constraint(0,2) {|a,b| a > b}
    prob
end

def main
    prob = problem()

    algs = [Backtracking.new(false, STATIC),
            Backtracking.new(false, FAIL_FIRST),
            Backtracking.new(true, STATIC),
            Backtracking.new(true, FAIL_FIRST)]

    puts "Solving problem with #{algs.length} algorithms. Depending on your"
    puts "hardware, this may take several minutes. For each run"
    puts "the output format is: alg,time,solns,nodes,checks"
    puts

    algs.each { |solver|

        solver.each_solution(prob) { |solution|
            # uncomment the following to double check each solution
            #solution.constraints.each {|c|
            #    puts 'FAILED' unless c.checkable? and c.check?
            #}
        }

        # print statistics
        print "#{solver.description},#{solver.time},#{solver.solutions}"
        puts ",#{solver.nodes_explored},#{solver.constraint_checks}"
    }
end

main()
