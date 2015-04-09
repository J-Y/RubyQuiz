
require 'thread'

class Queue
 # Retrieves next data from the queue, without pulling it off the queue.
 # If the queue is empty, the calling thread is
 # suspended until data is pushed onto the queue. 
 # If +non_block+ is true, the
 # thread isn't suspended, and an exception is raised.
  def peek(non_block=false)
    raise ThreadError, "queue empty" if non_block and empty?
    Thread.pass while (empty?)
    Thread.critical=true
      result=@que.first
    Thread.critical=false
    result
  end
end


class MyGenerator
    def initialize(enum=[],qsize=400,&block)
      @extras=[]
      @extrasmutex=Mutex.new
      init(enum,qsize,&block)
    end
        
    def init(enum,qsize,&block)
      @block=block
      @pos=0
      @enum=enum
      @q=q=SizedQueue.new(qsize)
      @thread=Thread.new{
        stop_thread
        enum.each{|item| 
          q<<item 
          stop_thread
        }
        block[self] if block
        i=0
        while i<@extras.size
          q.push @extrasmutex.synchronize { @extras[i] }
          i+=1
        end
      }
    end

    #no synchronization with thread by default
    def stop_thread; end
    def start_thread; end
        
    #should only be called from inside constructor's block
    def yield(item)
      @q.push item    
      stop_thread
    end

    def <<(item)
      @extrasmutex.synchronize { @extras<<item }
    end

    def begin!
      @thread.kill
      init(@enum,@q.max,&@block)
      0
    end
    
    def readahead1
      raise EOFError if eof?
      start_thread
      @q.peek
    rescue ThreadError:
      raise EOFError
    end

    def read1
      start_thread
      result=@q.pop
#      raise EOFError if !result && eof?
      @pos+=1
      result
    rescue ThreadError:
      raise EOFError
    end
    
    def eof?
      start_thread while @q.empty? and @thread.alive?
      @q.empty? and !@thread.alive?
    end

    def each(&block)
      begin!
      while(self.next?)
        block.call read1
      end
    end    
    include Enumerable
    
    attr :pos

    #methods for Generator compatibility:
    def rewind; begin!; self end
    alias current readahead1
    alias next read1
    alias end? eof?
    alias index pos
    def next?; !end? end
end

class MySynchronousGenerator < MyGenerator
  def stop_thread
    Thread.stop
  end
  
  def start_thread
    if @q.empty?
      @thread.wakeup 
      Thread.pass
    end
  end

end
