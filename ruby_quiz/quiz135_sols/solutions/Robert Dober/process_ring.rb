require 'labrador/enum/map'
require 'labrador/exp/open-proto'
require 'thread'

processes, cycles = ARGV.map.to_i

timer = new_proto{
  def init
    obj_variable :stopped, nil
    obj_variable :started, Time.now
    obj_variable :ellapsed, nil
  end
  def read
    self.ellapsed ||=
      stopped.tv_sec - started.tv_sec + (
          stopped.tv_usec - started.tv_usec
          ) / 1_000_000.0
  end
  def reset
    self.stopped = nil
    self.started = Time.now
  end
  def stop
    self.stopped = Time.now
  end
}
ring_element = new_proto(Prototype::OpenProto){
  define_method :init do |params|
    super
    obj_variable :thread, Thread.new{
    cycles.times do |i|
        m = lhs_queue.deq
        rhs_queue.enq "thread=#{count}::count=#{i}"
      end
    }
  end
}

startup_timer = timer.new
lqueue = Queue.new
all_processes = (2..processes).map{ |count|
  ring_element.new :count => count,
                   :lhs_queue => lqueue,
                   :rhs_queue => ( lqueue = Queue.new )
}
all_processes << ring_element.new(
    :count => 1,
    :lhs_queue => lqueue,
    :rhs_queue => all_processes.first.lhs_queue
    )
startup_timer.stop
run_timer = timer.new
all_processes.last.lhs_queue.enq "Can you please start"
all_processes.map.thread.map.join
run_timer.stop
puts "Startup time for #{processes} processes: %3.6fs" % startup_timer.read
puts "Runtime for #{processes} processes and #{cycles} cycles: %3.6fs" % run_timer.read
