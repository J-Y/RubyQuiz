require 'ai/csp'
require 'ai/csp/int'
require 'test/unit'

include AI::CSP
include AI::CSP::INT

class ConstraintTest < Test::Unit::TestCase

    def test_create
        domain = (0...5)
        v1, v2 = Variable.new(:v1, domain), Variable.new(:v2, domain)
        c = Constraint.new(v1, v2) { |a, b|
            a < b
        }
        assert_equal(false, c.checkable?, 'checkable')
        v1.value = v2.value = 4
        assert_equal(true, c.checkable?, 'checkable')
        assert_equal(false, c.check?, 'check')
        v1.value = 0
        assert_equal(true, c.check?, 'check')

        v1.value = v2.value = Variable::UNSET
        assert_equal([v1,v2], c.uninstantiated_variables, 'variables')
    end

    def test_propagate
        domain = (0...5)
        a,b,c = [:a,:b,:c].collect { |v| Variable.new(v,domain) }
        con = Constraint.new(a,b,c) { |x,y,z|
            x < y and y < z
        }

        assert(!con.forward_checkable?, 'f checkable?')
        a.value = b.value = 0
        assert(con.forward_checkable?, 'f checkable?')
        assert(!con.propagate(b, 0), 'propagate')
        assert_equal([], collect(c, 0), 'empty domain')

        [a,b,c].each {|v| v.unprune(0)}
        assert_equal([0,1,2,3,4], collect(c, 0), 'full domain')
        a.value = Variable::UNSET
        b.value, c.value = 2, 4
        assert(con.propagate(b, 0), 'propagate')
        assert_equal([0,1], collect(a, 10), 'pruned domain')
    end

    # this is very surface tests at the moment ...
    def test_special_constraints
        domain = (0...10)
        v1,v2,v3,v4 = %w(v1 v2 v3 v4).collect {|n| Variable.new(n,domain)}
        c_be_1 = BinaryEqual.new(v1, v2)
        c_be_2 = BinaryEqual.new(v2, v3)
        
        v1.value = 3
        assert(c_be_1.propagate(v1, 4), 'propagate should work')
        v3.value = 6
        assert(!c_be_2.propagate(v3, 4), 'propagate should fail')
        v2.value = 3
        assert(c_be_1.check?, 'satisfied')
        assert(!c_be_2.check?, 'not satisfied')

        c_bn_1 = BinaryNotEqual.new(v1, v4)
        c_bn_2 = BinaryNotEqual.new(v3, v4)
        assert(c_bn_1.propagate(v1, 3), 'propagate should work')
        assert(c_bn_2.propagate(v3, 3), 'propagate should work')
        assert_equal([0,1,2,4,5,7,8,9], collect(v4, 3), 'after pruning')

        v1.unprune(0); v2.unprune(0); v3.unprune(0); v4.unprune(0)
        c_eq = Equal.new(v1,v2,v3,v4)
        v1.value = v2.value = v3.value = v4.value = Variable::UNSET
        v3.value = 6
        assert(c_eq.propagate(v3, 1), 'should work')
        assert_equal([6], collect(v2, 1), 'only one left')

        v1.unprune(0); v2.unprune(0); v3.unprune(0); v4.unprune(0)
        c_neq = NotEqual.new(v1, v2, v3, v4)
        v1.value = 4
        v2.value = 5
        assert(c_neq.propagate(v1,0), 'not equal propagate')
        assert(c_neq.propagate(v2,0), 'not equal propagate')
        assert(c_neq.propagate(v3,0), 'not equal propagate')
        assert_equal([0,1,2,3,7,8,9], collect(v4, 0), 'those left')
    end

    def not_test_propatation_performance
        domain = (0...10000)
        v1 = Variable.new(:v1, domain)
        v2 = Variable.new(:v2, domain)
        con = Constraint.new(v1, v2) {|a,b| a!=b}
        #con = BinaryNotEqual.new(v1, v2)

        0.step(100, 4) {|value|
            v2.value = value
            con.propagate(v2, 3)
        }
    end

    def collect(variable, level)
        result = []
        variable.each_value(level) {|value| result << value}
        result
    end
end
