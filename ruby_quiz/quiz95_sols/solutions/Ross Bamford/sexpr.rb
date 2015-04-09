require 'sandbox'

module Sxp
  class << self
    def sxp(&blk)
      sb = Sandbox.new
      sb.main.instance_variable_set(:@blk,
                              blk || raise(LocalJumpError, "No block given"))
      sb.load("#{File.dirname(__FILE__)}/sandboxed.rb")
    end

    def sxpp(&blk)
      p(r = sxp(&blk)) || r
    end
  end
end

if $0 == __FILE__
  require 'test/unit'

  class Test::Unit::TestCase
    def sxp(&blk)
      Sxp.sxpp(&blk)  # use the printing version
    end
  end

  class ProvidedSxpTest < Test::Unit::TestCase
    def test_sxp_01
      assert_equal [:max, [:count, :name]], sxp{max(count(:name))}
    end

    def test_sxp_02
      assert_equal [:count, [:+, 3, 7]], sxp{count(3+7)}
    end

    def test_sxp_03
      assert_equal [:+, 3, :symbol], sxp{3+:symbol}
    end

    def test_sxp_04
      assert_equal [:+, 3, [:count, :field]], sxp{3+count(:field) }
    end

    def test_sxp_05
      assert_equal [:/, 7, :field], sxp{7/:field}
    end

    def test_sxp_06
      assert_equal [:>, :field, 5], sxp{:field > 5}
    end

    def test_sxp_07
      assert_equal 8, sxp{8}
    end

    def test_sxp_08
      assert_equal [:==, :field1, :field2], sxp{:field1 == :field2}
    end

    def test_sxp_09
      assert_raise(TypeError) { 7/:field }
    end

    def test_sxp_10
      assert_raise(NoMethodError) { 7+count(:field) }
    end

    def test_sxp_11
      assert_equal 11, 5+6
    end

    def test_sxp_12
      assert_raise(NoMethodError) { :field > 5 }
    end

    def test_sxp_13
      assert_equal [:+, 3, 'string'], sxp{3+'string'}
    end

    def test_sxp_14
      assert_equal [:abs, [:factorial, 3]], sxp{3.factorial.abs}
    end

    def test_sxp_15
      assert_raise(LocalJumpError) { sxp }
    end

    def test_sxp_16
      assert_equal 3.0, sxp{3.0}
    end

    def test_sxp_17
      assert_equal [:count, 3.0], sxp{count(3.0)}
    end

    # This test always fails right now, because string methods always get
    # called regardless. This is the same with Floats, but apparently not
    # on any immediate objects, or the standard Array / Hash classes,
    # Bignum, and so on...
    #
    #def test_sxp_18
    #  assert_equal [:+, 'longer', 'string'], sxp{'longer'+'string'}
    #end

    def test_sxp_19
      assert_equal [:+, [1,2], [:*, {3=>4}, 1100000000]], sxp{[1,2]+{3=>4}*1100000000}
    end

    def test_sxp_20
      assert_equal [:+, [1,2], [3,4]], sxp{[1,2]+[3,4]}
    end
  end

  class SanderLandSxpTest < Test::Unit::TestCase
    def test_more
      assert_equal [:==,[:^, 2, 3], [:^, 1, 1]], sxp{ 2^3 == 1^1}

      assert_equal [:==, 3.1415, 3] , sxp{3.0 + 0.1415 == 3}

      assert_equal [:|, [:==, [:+, :hello, :world], :helloworld],
        [:==, [:+, [:+, "hello", " "], "world"], "hello world"]] ,
        sxp{ (:hello + :world == :helloworld) | ('hello' + ' ' + 'world' == 'hello world') }

      assert_equal  [:==, [:+, [:abs, [:factorial, 3]], [:*, [:factorial, 4], 42]],
        [:+, [:+, 4000000, [:**, 2, 32]], [:%, 2.7, 1.1]]],
        sxp{ 3.factorial.abs + 4.factorial * 42 ==  4_000_000 + 2**32 + 2.7 % 1.1 }
    end
  end

  class RobinStockerSxpTest < Test::Unit::TestCase
    def test_number
      assert_equal 8, sxp { 8 }
      assert_equal [:+, 3, 4], sxp { 3 + 4 }
    end

    def test_environment
      assert_equal [:-, 10, [:count, [:*, :field, 4]]],
        sxp { 10 - count(:field * 4) }
      assert_raise(TypeError) { 7 / :field }
      assert_raise(NoMethodError) { 7 + count(:field) }
      assert_equal 11, 5 + 6
      assert_raise(NoMethodError) { :field > 5 }
    end
  end
end

__END__
