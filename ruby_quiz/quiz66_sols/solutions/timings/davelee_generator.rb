class DaveLeeGenerator

  def self.stateless(enum = nil, &block)
    g = new(enum, &block)
    g.instance_variable_set(:@stateless, true)
    g
  end

  def initialize(enum = nil, &block)
    @index = 0
    @stateless = false
    @block = nil
    if enum
      if enum.respond_to? :to_ary
        @array = enum.to_ary
      else
        block = proc { |g| enum.each { |x| g.yield x } }
      end
    elsif block
      @array = Array.new
      @block = block
      [ :current, :end? ].each do |symbol|
        method = method(symbol)
        metaclass.define_method(symbol) { |*args| fill_from_block; method.call(*args) }
      end
    else
      raise ArgumentError, 'Generate nothing?'
    end
  end

  def current
    raise EOFError if spent?
    @array[@index]
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
    spent?
  end

  attr_reader :index  
  alias_method :pos, :index

  def next
    result = current
    @index += 1
    result
  end

  def next?
    not end?
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
    Thread.stop unless @stateless
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
    Thread.new { Thread.stop; @block.call(self) }
  end

  def fill_from_block
    return if not spent? or @block_exhausted
    @thread ||= new_fill_thread
    return unless @thread.alive?
    @thread.wakeup
    if @stateless
      @block_exhausted = @thread.join(1).nil?
    else
      Thread.pass while spent? and @thread.alive?
    end
    @thread.stop unless @thread.stop?
  end

end
