#!/usr/local/bin/ruby -w

class FasterGenerator
  def initialize( enum = nil )
    @index = 0
    if enum.nil?
      @queue = Array.new
      yield self
    else
      @queue = enum.to_a
    end
  end
  
  attr_reader :index
  alias_method :pos, :index
  
  def current
    raise EOFError, "No more elements available." if end?
    
    @queue[@index]
  end
  
  def next
    raise EOFError, "No more elements available." if end?
    
    @queue[(@index += 1) - 1]
  end
  
  def next?
    not end?
  end
  
  def end?
    @index >= @queue.size
  end
  
  def rewind
    @index = 0
    
    self
  end
  
  def yield( object )
    @queue << object
  end
  
  include Enumerable
  
  def each( &block )
    @queue.each(&block)
    
    self
  end
end

#class SyncEnumerator
#  include Enumerable
#
#  def initialize( *enums )
#    @gens = enums.map { |e| FasterGenerator.new(e) }
#  end
#
#  def size
#    @gens.size
#  end
#
#  def length
#    @gens.length
#  end
#
#  def end?(i = nil)
#    if i.nil?
#      @gens.detect { |g| g.end? } ? true : false
#    else
#      @gens[i].end?
#    end
#  end
#
#  def each
#    @gens.each { |g| g.rewind }
#
#    loop do
#      count = 0
#
#      ret = @gens.map { |g|
#	      if g.end?
#	        count += 1
#	        nil
#	      else
#	        g.next
#	      end
#      }
#
#      if count == @gens.size
#	      break
#      end
#
#      yield ret
#    end
#
#    self
#  end
#end

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__

require 'test/unit'

class TC_Generator < Test::Unit::TestCase
  def test_block1
    g = FasterGenerator.new { |g|
      # no yield's
    }

    assert_equal(0, g.pos)
    assert_raises(EOFError) { g.current }
  end

  def test_block2
    g = FasterGenerator.new { |g|
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

  def test_each
    a = [5, 6, 7, 8, 9]

    g = FasterGenerator.new(a)

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

class TC_SyncEnumerator < Test::Unit::TestCase
  def test_each
    r = ['a'..'f', 1..10, 10..20]
    ra = r.map { |x| x.to_a }

    a = (0...(ra.map {|x| x.size}.max)).map { |i| ra.map { |x| x[i] } }

    s = SyncEnumerator.new(*r)

    i = 0

    s.each { |x|
      assert_equal(a[i], x)

      i += 1

      break if i == 3
    }

    assert_equal(3, i)

    i = 0

    s.each { |x|
      assert_equal(a[i], x)

      i += 1
    }

    assert_equal(a.size, i)
  end
end
