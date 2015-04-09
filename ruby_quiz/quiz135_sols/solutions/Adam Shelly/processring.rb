#processring.rb
# for Ruby Quiz #135
# Adam Shelly

#Implements a virtual machine and a compiler for a simple language
# language definition:
# types: ints, strings
# variables don't need to be declared in advance (works like ruby)
# only 3 keywords: 'exit', 'if' and 'while',
#   the latter two take the form 'keyword (condition) { body }'.
#   the parens and brackets are required
# only 2 operators: '+' and '-'.
# 4 builtin functions: '_peek' returns true if any messages waiting for this proceses
#                             '_get' returns first pending message.
#                             '_send(id, message)' sends message to process with given id
#                             '_puts(message)' writes message to stdout
# '%' before a name indicates process variable.
#    process variables include:  %id = current process id
#                                         %last = value of last expression
# strictly left associative, use parentheses to group.
#    be careful with assignments:  'n = 1+1' ==  '(n=1)+1'
#              you usually want to do 'n = (1+1)'

# Here are the two programs we will execute.
# this one just forwards any message to the next process
prog1 = <<PROG
while (0) { _get }
while (1) {
  if (_peek) {
    msg =_get
    _send ((%id+1),msg)
  }
}
PROG

# This one generates a message and sends it to process 0, n times.
# It will be the last process so we can close the ring.
prog2 = <<PROG
n = _get
_send (0,"chunky bacon")
while (n ) {
  if (_peek) {
    msg = _get
    _send (0,msg)
    n = ( n - 1)
    _puts ( n )
  }
}
_puts ( "done" )
exit
PROG

# The Compiler turns program text into "assembly"
class Compiler
    @@symbols = {}
    #register keywords
    %w{while if end exit}.each{|kw| @@symbols[kw]=kw.to_sym}
    #register builtins
    %w{_peek _get _send _puts}.each{|bi| @@symbols[bi] = :builtin}

  def self.compile code
    asm = []
    text = code
    text = text.dup #don't destroy original code
    token,name = parse text
    while (token)
      p token if $DEBUG
      case token
        when :while,:if,:exit,:end,:add,:subtract,:assign,:comma
          asm << token
        when :localvar,:procvar,:builtin,:num,:string
          asm << token
          asm << name
        when :startgroup,:startblock
          asm << token
          asm << 0                        #placeholder for size of group/block
        when :endgroup
          startgroup = asm.rindex(:startgroup)
          asm[startgroup] = :group
          asm[startgroup+1] = asm.size-startgroup-2  #store groupsize
        when :endblock
          startblock = asm.rindex(:startblock)
          asm[startblock] = :block
          asm[startblock+1] = asm.size-startblock  #store blocksize
          asm << :endblock
          asm << asm.size+1 #placeholder for looptarget (default is next inst.)
      end
      token,name = parse text
    end
    return asm
  end

private
  def self.parse text, vartype = :localvar
    pt = 0;
    p "parse: #{text}" if $DEBUG
    while (true)
      case (c = text[pt,1])
      when ''          #EOF
        return nil

      when /\s/         #skip whitespace
        pt+=1
        next

      when /\d/         #integers
        v = text[pt..-1].to_i
        text.slice!(0..pt+v.to_s.length-1) #remove number
        return :num,v

      when /\w/        #identifiers
        name = /\w*/.match(text[pt..-1])[0]
        text.slice!(0..pt+name.length-1) #remove name
        sym = @@symbols[name]
        sym = register_var(name,vartype) if !sym #unknown identifier is variable
        return sym,name

      when '"'       #strings
        name = /".*?[^\\]"/m.match(text[pt..-1])[0]
        text.slice!(0..pt+name.length-1) #remove name
        return :string, name

      when '%'       #processes variables
        text.slice!(0..pt)
        token,name = parse text,:procvar
        raise "invalid process variable" if token!= :procvar
        return token,name

      when '=':    #punctuation
        text.slice!(0..pt)
        return :assign, c
      when ',':
        text.slice!(0..pt)
        return :comma,c
      when '+'
          text.slice!(0..pt)
          return :add,'+'
      when '-'
          text.slice!(0..pt)
          return :subtract,'-'
      when '('
          text.slice!(0..pt)
          return :startgroup, c
      when ')'
          text.slice!(0..pt)
          return :endgroup, c
      when '{'
          text.slice!(0..pt)
          return :startblock, c
      when '}'
          text.slice!(0..pt)
          return :endblock, c
      end #case
    end #while
  end

  def self.register_var name,type
    @@symbols[name] = type
  end
end


#The cpu instruction set.
#each instruction is the equivalent of a VM bytecode.
class InstructionSet
  def initialize  cpu
    @cpu = cpu
  end

  def exit proc       #halt the cpu
    @cpu.halt
  end
  def end proc    #end the current process
    @cpu.end_process proc.id
  end

  def while proc
    loopp = proc.pc-1
    test = proc.exec
    blocksize = proc.exec
    if test && test != 0
      #if we are going to loop, store the loop start address at the end of the block
      proc.pm[proc.pc+blocksize-1] = loopp
    else
      proc.pc += blocksize
    end
  end
  def if proc
    test = proc.exec
    blocksize = proc.exec
    if !test || test == 0
      proc.pc += blocksize
    end
  end

  def block proc
    blocksize = proc.pop
  end
  def endblock proc
    jumptarg = proc.pop   #after block, maybe jump somewhere
    proc.pc = jumptarg
  end

  def group proc
    groupsize = proc.pop
    endgroup = proc.pc+groupsize
    while (proc.pc < endgroup)
      val = proc.exec
    end
    return val
  end

  def num proc
    proc.pop
  end
  def string proc
    proc.pop
  end
  def builtin proc
    inst = proc.pop
    @cpu.send(inst,proc)
  end
  def localvar proc
    varname = proc.pop
    proc.getvar varname
  end
  def procvar proc
    varname = proc.pop
    proc.send varname
  end
  def assign proc
    proc.setvar(proc.exec)
  end
  def comma proc
    return :comma
  end
  def add proc
    return proc.last + proc.exec
  end
  def subtract proc
    return proc.last - proc.exec
  end

  #returns elements of group as array
  #used to evaluate arguments for function call
  def ungroup proc
    args = []
    proc.pop #ignore :group
    groupsize = proc.pop
    endgroup = proc.pc+groupsize
    while (proc.pc < endgroup)
      arg = proc.exec
      args << arg unless arg == :comma
    end
    return args
  end
end


#the CPU
# acts as process scheduler
# processes run for TIMESLICE instructions, or until they send or get a message.
# in the latter case, control switches to the process with a message pending for the longest time
class CPU
  TIMESLICE = 10

  # CProcess is a process on our virtual machine
  # don't create directly, use CPU#add_process
  class CProcess
    attr_accessor :pm,:pc,:id,:last
    def initialize id, code, vm
      @id = id
      @pm = code    #program memory
      @pc = 0         #program counter
      @vars = {}
      @curvar = nil
      @vm = vm
    end

    #executes a VM instruction, advances program counter
    def exec
      inst = @pm[@pc]
      p to_s if $DEBUG
      @pc+=1
      @last = @vm.send(inst,self)
    end
    def pop
      @pc+=1
      @pm[@pc-1]
    end

    def getvar name
      @curvar = name
      @vars[name]||=0
    end
    def setvar value
      @vars[@curvar] = value
    end

    def to_s
      "#{@id}@#{@pc}: #{@pm[@pc]} (#{@pm[@pc+1]})"
    end
  end #class Process

  def initialize
    @processes = []
    @messages = []
    @i = InstructionSet.new self
    @queue=[[],[]]  #scheduling queues
  end

  def add_process code
    asm = code.dup
    asm << :end
    id = @processes.size
    @processes << CProcess.new(id, asm,@i)
    @messages[id] = []
    @queue[0] << id
    @cur_proc_id = id
  end

  #stop processes by swapping it out if it is running, and removing it from queues.
  def end_process id
    taskswap 0 if @cur_proc_id == id
    @processes -= [id]
    @queue[0] -= [id]
    @queue[1] -= [id]
  end

  def start
    @running = true
    run
  end
  def halt
    @running = false
  end

  #inject a message into the system
  def send_msg proc_id,msg
    @messages[proc_id]<< msg
    @queue[1]<<proc_id
  end

private
  #run the scheduler
  def run
    @timeslice = 0
    while (@running)
      @processes[@cur_proc_id].exec
      @timeslice+=1
      if (@timeslice > TIMESLICE)
        taskswap 0
      end
    end
  end

  #switch to the next process waiting at this priority level
  def taskswap priority
    @cur_proc_id = @queue[priority].shift||@cur_proc_id
    (@queue[priority] << @cur_proc_id) if priority == 0
    @timeslice = 0
  end

  ## built-in messaging functions
  def _peek proc
    @messages[proc.id][0]
  end
  def _get proc
    retval = @messages[proc.id].shift
    taskswap 1
    return retval
  end
  def _send proc
    #send puts the target process on the high priority queue
    args = @i.ungroup proc
    @messages[args[0]] << args[1]
    @queue[1]<<args[0]
    taskswap 1
    args[1]
  end

  def _puts proc
    args = @i.ungroup proc
    puts args
  end
end

if __FILE__ == $0
puts "usage: #{$0} processes cycles" or exit if ARGV.size < 2
processes, cycles = ARGV.map { |n| n.to_i }

puts "Timer started."
start_time = Time.now
puts "Creating #{processes} processes"

code1 = Compiler.compile prog1
code2 = Compiler.compile prog2
cpu = CPU.new
(processes-1).times { cpu.add_process code1 }
last_proc = cpu.add_process code2

puts "Sending a message around the ring #{cycles} times..."
cpu.send_msg last_proc,cycles
cpu.start
puts "Time in seconds:  #{(Time.now - start_time)}"
end
