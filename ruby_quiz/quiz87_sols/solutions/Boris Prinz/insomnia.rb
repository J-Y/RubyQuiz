class Insomnia
  # It's really sick to call this method 'do',
  # but I can't think of a better name...
  def do(&block)
    @blocks[@t] << block
  end

  def sleep(seconds)
    @t += seconds
  end

  def run
    times = @blocks.keys.sort
    t_now = times.min
    times.each do |t|
      Kernel.sleep(t - t_now)
      t_now = t
      @blocks[t].each {|b| b.call}
    end
  end

  def initialize
    @blocks = Hash.new {|h, t| h[t] = []}
    @t = 0
    yield(self)
    run
  end
end

Insomnia.new do |i|
  i.do { puts "Something will explode in ten seconds:" }
  i.sleep(10)
  i.do { puts "Boom!" }

  # countdown:
  1.upto(9) do |num|
    i.sleep(-1)
    i.do { puts num.to_s }
  end
end
