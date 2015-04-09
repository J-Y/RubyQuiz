class MyGenerator

  def self.stateless(enum = nil, &block)
    g = new(enum, &block)
    g.instance_variable_set(:@stateless, true)
    g
  end

  def initialize(enum = nil, &block)
    @index = 0
    @stateless = false
    if enum
      if enum.respond_to? :to_ary
        @array = enum.to_ary
      else
        block = proc { |g| enum.each { |x| g.yield x } }
      end
    end
    if block
      @array = Array.new
      @block = block
      [ :current, :end?, :next?, :next ].each do |symbol|
        method = method(symbol)
        metaclass.define_method(symbol) { |*args| fill_from_block; method.call(*args) }
      end
    end
    raise ArgumentError, 'Generate nothing?' unless @array
  end

  def current
    @array.fetch(@index) rescue raise EOFError
  end

  def each(&each_block)
    if @array
      @array.each(&each_block)
    else
      x = Object.new
      def x.yield(value); each_block.call(value); end
      @block.call(x)
    end  
    self
  end

  def end?
    @index >= @array.size
  end

  attr_reader :index  
  alias_method :pos, :index

  def next
    begin
      result = @array.fetch(@index)
    rescue Exception => e
puts e if @index != 4
      raise EOFError
    end
    @index += 1
    result
  end

  def next?
    @index < @array.size
  end

  def rewind
    @index = 0
    if @block
      @array = Array.new if @block
      @thread = new_fill_thread
    end
    self
  end

  def yield(value)
    @array << value
    Thread.stop if not @stateless
    self
  end

  private

  def spent?
    @index >= @array.size
  end

  def metaclass
    class << self
      public_class_method :define_method
      self
    end
  end

  def new_fill_thread
    Thread.new { @block.call(self) }
  end

  def fill_from_block
    return if not spent? or @block_exhausted
    @thread ||= new_fill_thread
    return unless @thread.alive?
    if @stateless
      @block_exhausted = @thread.join(1)
    else
      while spent? and @thread.alive?
        @thread.wakeup
        Thread.pass
      end
    end
  end

end
