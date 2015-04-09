module Kernel
  alias normal_sleep sleep
  def sleep(seconds)
    normal_sleep(seconds) and return if seconds >= 0
    priorities = {}
    (Thread.list - [Thread.current]).each do |thread|
      priorities[thread] = thread.priority
      thread.priority = Thread.current.priority-1
    end
    Thread.new do
      normal_sleep(-seconds)
      priorities.each do |thread, priority|
        thread.priority = priority
      end
    end
  end
end
