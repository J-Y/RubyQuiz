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

  attr_reader :ops

  def initialize(time = 0, &block)
    @ops = Hash.new { |h,k| h[k] = [] }
    @ops[time] << block if block
    @time = time
  end

  def <<(comp)
    case comp
    when Sleep
      @time += comp.time
    when Comp
      comp.ops.each { |t,bs| @ops[t+@time].concat bs }
    when Proc
      @ops[@time] << comp
    end
    self
  end

  def run
    ref_time = @ops.keys.min
    ts = @ops.map do |t,bs|
      Thread.new(bs) do |bs|
        sleep(t-ref_time)
        bs.each { |b| b.call(t) }
      end
    end
    ts.each { |t| t.join }
  end

end
