#!/usr/bin/env ruby -wKU

begin
  require "fastthread"
  puts "Using the fastthread library."
rescue LoadError
  require "thread"
  puts "Using the standard Ruby thread library."
end

module MRing
  class Forward
    def initialize(count, parent)
      @child = count.zero? ? parent : Forward.new(count - 1, parent)
      @queue = Queue.new
      
      run
    end
    
    def send_message(message)
      @queue.enq message
    end

    private
    
    def run
      Thread.new do
        loop do
          message = @queue.deq
          if message =~ /\A(\d+)\s+(.+)/
            @child.send_message "#{$1.to_i + 1} #{$2}"
          end
        end
      end
    end
  end  

  class Parent < Forward
    def initialize(processes, cycles)
      @processes = processes
      @cycles    = cycles
      
      puts "Creating #{processes} processes..."
      super(processes, self)
    end
    
    private
    
    def run
      puts "Timer started."
      start_time = Time.now
      puts "Sending a message around the ring #{@cycles} times..."
      @cycles.times do
        @child.send_message "0 Ring message"
        raise "Failure" unless @queue.deq =~ /\A#{@processes} Ring message\Z/
      end
      puts "Done:  success."
      puts "Time in seconds:  #{(Time.now - start_time).to_i}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  unless ARGV.size == 2
    abort "Usage:  #{File.basename($PROGRAM_NAME)} PROCESSES CYCLES"
  end
  processes, cycles = ARGV.map { |n| n.to_i }
  
  MRing::Parent.new(processes, cycles)
end
