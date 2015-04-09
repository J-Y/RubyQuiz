module Kernel
  def n_sleep(n_sleep_time)
    Thread.current.priority = -n_sleep_time
  end
end


# test stuff
if __FILE__ == $0
  Thread.new { n_sleep(-3); 1.upto(10) {print "A"; sleep(0.1)} }
  Thread.new { n_sleep( 1); 1.upto(10) {print "B"; sleep(0.1)} }
  Thread.new { n_sleep(-2); 1.upto(10) {print "C"; sleep(0.1)} }
  n_sleep(10); 1.upto(10) {print "m"; sleep(0.1)}
  loop {break if Thread.list.size == 1}
end
