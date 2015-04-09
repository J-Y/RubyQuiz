require 'ai/csp'
require 'test/unit'

include AI::CSP

class ConstraintTest < Test::Unit::TestCase

    def test_create
        domain = (0...5)
        v1, v2, v3 = [:v1,:v2,:v3].collect {|n| Variable.new(n, domain)}
        problem = Problem.new([v1, v2, v3])
        c1 = problem.add_constraint(:v1, :v2) {|a,b| a == b}
        c2 = Constraint.new(v1, v2) { |a, b|
            a < b
        }
        rc2 = problem.add_constraint(c2)
        c3 = problem.add_constraint(v2, v3) {|a,b| a+b == 6}

        assert_equal(c2, rc2, 'same constraint')
        assert_equal([c1,c2,c3], problem.constraints, 'constraints')
        assert_equal([c1,c2], collect_cons(problem,v1), 'constraints')
    end

    def collect_cons(problem, variable)
        result = []
        problem.each_constraint(variable) {|c| result << c}
        result
    end
end
