# Num. 135
# process_rings.rb
require 'drb'

BasePort = 7654

class RingParent
  def initialize(processes = 3, cycles = 5)
    @processes = processes
    @cycles = cycles
    @message = "Message from parent\n"
  end

  def start
    spawn_processes
    connect_ring
    send_messages
  end

  def spawn_processes
    t = []
    for i in 0...@processes-1
      t << Thread.new do
        RingMember.new(BasePort+i, BasePort+i+1, self)
      end
    end
    t << Thread.new do
      RingMember.new(BasePort+@processes-1, BasePort)
    end
  end

  def connect_ring
    DRb.start_service
    @ring = DRbObject.new(nil, "druby://127.0.0.1:#{BasePort}")
  end

  def send_messages
    @start = Time.now
    @cycles.times do
      @ring.parent_receive("Hi ring!")
    end
  end

  def return_message(message)
    puts "Parent: Got message back- circulation time: #{Time.now - @start}"
  end
end

class RingMember
  def initialize(port, next_port, parent = nil)
    @port = port
    @parent = parent
    @current_message = ""
    @next_member = connect_next(next_port)
    DRBService.new(self, @port)
  end

  def connect_next(port)
    DRb.start_service
    DRbObject.new(nil, "druby://127.0.0.1:#{port}")
  end

  def parent_receive(message)
    @current_message = message
    forward_message(@current_message)
  end

  def receive_message(message)
    begin
      message == @current_message ?
        (@parent.return_message(message);(@current_message = "")) :
        forward_message(message)
    rescue
      puts "#{@port}: Received duplicate message, couldn't talk to parent: #{$!}"
    end
  end

  def forward_message(message)
    @next_member.receive_message(message)
  end

  def test(message)
    return "#{@port}: Got message #{message}"
  end
end

class DRBService
  def initialize(process, port)
    DRb.start_service("druby://:#{port}", process)
    DRb.thread.join
  end
end

processes = ARGV[0].to_i
cycles = ARGV[1].to_i
parent = RingParent.new(processes, cycles)
