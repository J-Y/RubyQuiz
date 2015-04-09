class RossBamfordGenerator
  include Enumerable
  
  def initialize(enum = nil, &blk)
    if enum
      blk = lambda { |g| enum.each { |i| g.yield i } }
    end
    
    init_generator(blk)
  end

  # This is called from the block, i.e. on the blk_thread.
  # It sets the value then stops this thread, waking up
  # the user thread instead.
  def yield(obj)
    Thread.critical = true
    begin
      @next << obj
      @user_thread.run
      Thread.stop
    ensure
      Thread.critical = false
    end
    
    self
  end

  # If @next is nil and @blk_thread is still there, this
  # wakes it up and suspends this thread (it will be notified
  # when the block next calls yield). After the block exits
  # @blk_thread should be nil.
  #
  # After this, true is returned if there's no next item.
  def end?
    if @next.empty? && @blk_thread
      Thread.critical = true
      begin
        @user_thread = Thread.current
        @blk_thread.run
        Thread.stop        
      ensure
        @user_thread = nil
        Thread.critical = false
      end
    end

    @next.empty?
  end

  def next?
    !self.end?
  end

  def current   
    raise EOFError if self.end?
    @next.first
  end

  def next
    raise EOFError if self.end?
    @pos += 1
    @next.shift
  end

  def rewind    
    @blk_thread.kill if @blk_thread
    init_generator(@blk)
    self
  end

  # careful with infinite blocks here!
  def each
    rewind
    yield self.next until self.end?
  end

  def to_a
    self.inject([]) { |ary, i| ary << i }
  end

  attr_reader :pos

  private
  
  # sets up ivars and makes a new thread (stopped) that
  # will call the block. We'll then use the yield calls
  # from the block to wait the thread and give control
  # back to the user thread.
  #
  # This thread is notified by +next+ when first called,
  # and as new items are needed.
  def init_generator(blk)
    @next, @pos = [], 0
    
    if @blk = blk
      @blk_thread = Thread.new do
        # wait for it... (at first next call)
        Thread.stop

        begin
          blk.call(self)
        ensure
          @blk_thread = nil
          @user_thread.run
        end
      end
    else
      @blk_thread = nil
    end

    if @blk_thread
      sleep 0.01 until @blk_thread.stop?
    end
  end
end

if $0 == __FILE__
  require 'test/unit'

  class TC_TGenerator < Test::Unit::TestCase
    def test_block1
      g = TGenerator.new { |g|
        # no yield's
      }
      
      assert_equal(0, g.pos)
      assert_raises(EOFError) { g.current }
    end
    
    def test_block2
      g = TGenerator.new { |g|
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
      
      g = TGenerator.new(a)

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

    def test_to_a
      g = TGenerator.new { |g| [1,2,3,4,5,6,7,8,9,10].each { |i| g.yield i } }
      assert_equal [1,2,3,4,5,6,7,8,9,10], g.to_a
    end
    
    def test_endless
      # 1, 2, 3, 4 ... etc
      g = TGenerator.new do |g|
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
  end  
end
