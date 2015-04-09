class Sleep

  attr_reader :time

  def initialize time
    @time = time
  end

  def <<(comp)
    if Sleep === comp
      @time += comp.time
      self
    else
      Comp.new(time) << comp
    end
  end

end

class Comp

  Op = Struct.new :time, :op

  attr_reader :ops

  def initialize(time = 0, &block)
    @ops = []
    @ops << Op.new(time, block) if block
    @time = time
  end

  def <<(comp)
    case comp
    when Sleep
      t = comp.time
      @time += t
    when Comp
      @ops.concat comp.ops.map { |o| Op.new(o.time+@time, o.op) }
    when Proc
      @ops << Op.new(@time, comp)
    end
    self
  end

  def run
    h = Hash.new { |h,k| h[k] = [] }
    @ops.each do |c|
      h[ c.time ] << c.op
    end
    order = h.keys.sort
    time = order[0]
    ref_time = time
    order.each do |t|
      sleep(t-time)
      h[t].each { |b| b.call(t) }
      time = t
    end
  end

end
