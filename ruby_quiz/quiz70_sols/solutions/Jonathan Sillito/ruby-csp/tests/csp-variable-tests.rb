require 'ai/csp'
require 'test/unit'

include AI::CSP

class VariableTest < Test::Unit::TestCase

    def test_create
        v = Variable.new(:v1, [11,12,13,14])
        assert_equal(false,v.instantiated?,'instantiated')
        v.value = 12
        assert_equal(true,v.instantiated?,'instantiated')
        assert_equal(4,v.domain_size,'domain size')
        assert_equal(4,v.domain_size(2),'domain size')
        assert_equal(false,v.domain_empty?,'domain empty')
    end

    def test_prune
        domain = %w(a b c d e f g h)
        v = Variable.new(:v1, domain)
        domain.each_with_index {|value,i|
            v.prune(i*2, i)
            assert_equal(true, v.pruned?(i*2, i), 'pruned?')
            assert_equal(false, v.pruned?(i*2-1, i), 'pruned?')
            assert_equal(true, v.pruned?(i*2+1, i), 'pruned?')
        }

        assert_equal(true, v.pruned?(0), 'pruned at level?')
        assert_equal(false, v.pruned?(1), 'pruned at level?')
        assert_equal(true, v.pruned?(4), 'pruned at level?')
        assert_equal([], collect(v, (domain.length-1)*2), 'empty domain')
        assert_equal(0, v.domain_size((domain.length-1)*2), 'domain size')
        assert_equal(domain.length-1, v.domain_size(1), 'domain size')
        
        assert_equal(%w(d e f g h), collect(v, 4), 'pruned domain')
        v.unprune(4)
        assert_equal(%w(c d e f g h), collect(v, 4), 'unpruned domain')
        assert_equal(%w(c d e f g h), collect(v, 6), 'unpruned domain')
        assert_equal(%w(b c d e f g h), collect(v, 0), 'empty domain')
        v.unprune(0)
        assert_equal(domain, collect(v,0), 'full domain')
        assert_equal(domain, collect(v,5), 'full domain')
    end

    def collect(variable, level)
        result = []
        variable.each_value(level) {|value| result << value}
        result
    end
end
