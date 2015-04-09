require 'test/unit'

raise ArgumentError, "Usage: tests.rb <fn1> [..[fnN]]", [] if ARGV.empty?

sc, ec = [], []
ObjectSpace.each_object(Class) { |e| sc << e }
ARGV.each { |f| require f }
ObjectSpace.each_object(Class) { |e| ec << e }
$generators = (ec - sc).select { |c| c.name =~ /Generator/ }

class TC_TGenerator < Test::Unit::TestCase
  def test_block1
    $generators.each do |clz|
      g = clz.new { |g|
        # no yield's
      }
    
      assert_equal(0, g.pos)
      assert_raises(EOFError) { g.current }
    end      
  end
  
  def test_block2
    $generators.each do |clz|
      g = clz.new { |g|
        for i in 'A'..'C'
          g.yield i
        end
        
        g.yield 'Z'
      }
      
      assert_equal(0, g.pos)
      assert_equal('A', g.current)
      
      assert_equal(true, g.next?)
      assert_equal(0, g.pos)
      assert_equal('A', g.current)
      assert_equal(0, g.pos)
      assert_equal('A', g.next)
      
      assert_equal(1, g.pos)
      assert_equal(true, g.next?)
      assert_equal(1, g.pos)
      assert_equal('B', g.current)
      assert_equal(1, g.pos)
      assert_equal('B', g.next)
      
      assert_equal(g, g.rewind)
      
      assert_equal(0, g.pos)
      assert_equal('A', g.current)
      
      assert_equal(true, g.next?)
      assert_equal(0, g.pos)
      assert_equal('A', g.current)
      assert_equal(0, g.pos)
      assert_equal('A', g.next)
      
      assert_equal(1, g.pos)
      assert_equal(true, g.next?)
      assert_equal(1, g.pos)
      assert_equal('B', g.current)
      assert_equal(1, g.pos)
      assert_equal('B', g.next)
      
      assert_equal(2, g.pos)
      assert_equal(true, g.next?)
      assert_equal(2, g.pos)
      assert_equal('C', g.current)
      assert_equal(2, g.pos)
      assert_equal('C', g.next)
      
      assert_equal(3, g.pos)
      assert_equal(true, g.next?)
      assert_equal(3, g.pos)
      assert_equal('Z', g.current)
      assert_equal(3, g.pos)
      assert_equal('Z', g.next)
      
      assert_equal(4, g.pos)
      assert_equal(false, g.next?)
      assert_raises(EOFError) { g.next }
    end
  end
  
  def test_each
    $generators.each do |clz|
      a = [5, 6, 7, 8, 9]
      
      g = clz.new(a)

      i = 0
      
      g.each { |x|
        assert_equal(a[i], x)
        
        i += 1
        
        break if i == 3
      }
      
      assert_equal(3, i)
      
      i = 0
      
      g.each { |x|
        assert_equal(a[i], x)
        
        i += 1
      }
      
      assert_equal(5, i)
    end
  end

  def test_endless
    main = Thread.current
    
    $generators.each do |clz|
      t = Thread.new do
        # 1, 2, 3, 4 ... etc
        g = clz.new do |g|
          i = 0 
          while true
            g.yield(i)
            i += 1
          end
        end

        assert_equal 0, g.next
        
        999.times do |n|       
          assert_equal(n+1, g.next)
        end

        assert_equal 1000, g.current

        500.times do |n|        
          assert_equal(n + 1000, g.next)
        end

        g.rewind

        assert_equal 0, g.next
        assert_equal 1, g.next     
      end

      c = 0
      until t.stop?
        if c >= 30
          t.kill
          fail "Endless iterators unsupported"
        end

        c += 1
        sleep(1)
      end
    end
  end

  class C
    def value=(x)
      @value = x
    end
    def each
      loop do
        yield @value
      end
    end
  end

  def test_realtime
    $generators.each do |clz|
      c = C.new
      g = clz.new(c)
      3.times do |i|
        c.value = i
        assert_equal(i, g.next())
      end
    end
  end
end

