require 'priority_queue'

require 'test/unit'

class TC_pq_test < Test::Unit::TestCase
  def setup
    @q = PriorityQueue.new
  end

  def test_pop_nil
    assert_equal(nil, @q.pop_min)
  end
  
  def test_push_pop
    20.times do | i |
      @q.push i, i
    end

    20.times do | i |
      assert_equal(i, @q.pop_min)
    end

    assert_equal(nil, @q.pop_min)
    assert_equal(nil, @q.min)
  end

  def test_decrease_priority

    20.times do | i |
      @q.push i, i / 20.0
    end

    assert_equal(0, @q.pop_min)

    @q.decrease_priority(10, -1)
    @q.decrease_priority(11, -1)

    [10, 11, (1..9).to_a, (12..19).to_a, nil].flatten.each do | shall |
      assert_equal(shall, @q.pop_min)
    end
  end

  def test_to_dot    
    5.times do | i |
      @q.push "N#{i}", i
    end
    @q.pop_min
    assert_equal(
    ['digraph fibonaccy_heap {',
    '  NODE [label="N1 (1)",shape=box];',
    '    NODE [label="N3 (3)",shape=box];',
    '      NODE [label="N4 (4)",shape=box];',
    '    NODE -> NODE;',
    '  NODE -> NODE;',
    '    NODE [label="N2 (2)",shape=box];',
    '  NODE -> NODE;',
    '}',''].join("\n"),  @q.to_dot.gsub(/NODE[0-9]*/, 'NODE'))
  end
end
