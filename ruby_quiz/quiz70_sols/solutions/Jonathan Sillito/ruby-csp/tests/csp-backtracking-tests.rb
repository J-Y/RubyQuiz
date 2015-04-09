require 'ai/csp'
require 'test/unit'

include AI::CSP

class ConstraintTest < Test::Unit::TestCase

    def test_solve
        domain = (0...5)
        v1, v2, v3 = [:v1,:v2,:v3].collect {|n| Variable.new(n, domain)}
        problem1 = Problem.new([v1, v2, v3])
        problem1.add_constraint(v1, v2) {|a,b|
            a < b
        }
        problem1.add_constraint(v1,v2,v3) {|a,b,c|
            a+b+2 == c
        }

        algs = [b1 = Backtracking.new(false, STATIC),
                b2 = Backtracking.new(false, FAIL_FIRST),
                b3 = Backtracking.new(true, STATIC),
                b4 = Backtracking.new(true, FAIL_FIRST)]

        algs.each {|alg| solve(problem1, alg, 2) }
        assert(b1.nodes_explored >= b2.nodes_explored, 'nodes explored')
        assert(b2.nodes_explored >= b3.nodes_explored, 'nodes explored')
        assert(b3.nodes_explored >= b4.nodes_explored, 'nodes explored')

        domain = (1..10)
        vars = [:a,:b,:c,:d,:e,:f].collect {|n| Variable.new(n,domain)}
        problem2 = Problem.new(vars)
        c1 = problem2.add_constraint(:a,:b,:c) { |a,b,c| 
            a < b and b < c and b%3==0
        }
        c2 = problem2.add_constraint(:d,:e,:f) { |d,e,f|
            d%2==0 and e%2==0 and f%2==0 and (d+e > f)
        }
        c3 = problem2.add_constraint(:c,:f) { |c,f|
            c%4 == 0 and c+f==10
        }
        c4 = problem2.add_constraint(:c, :e) {|c,e|
            c==e
        }

        algs.each {|alg| solve(problem2, alg, 43) }
        assert(b1.nodes_explored >= b2.nodes_explored, 'nodes explored')
        assert(b2.nodes_explored >= b3.nodes_explored, 'nodes explored')
        assert(b3.nodes_explored >= b4.nodes_explored, 'nodes explored')
    end

    def solve(problem, alg, solutions)
        alg.each_solution(problem) { |s| 
            s.constraints.each {|c| assert(c.check?, 'check')}
        }
        assert_equal(solutions, alg.solutions, alg.description)
    end
end
