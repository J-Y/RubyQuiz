class NegativeProc < Proc; end
class ProcStack
  def initialize(*args)
    @negative = args.shift if args.first == true
    @stack = args
  end

  def + code
    new_stack = @stack.dup

    if code.is_a? NegativeProc
      new_stack.insert(-2, code)
      new_stack.unshift(true)
    elsif code.respond_to? 'call'
      if @negative
        new_stack.insert(-3, code)
      else
        new_stack.push(code)
      end
    end

    ProcStack.new(*new_stack)
  end

  def call
    @stack.each { |p| p.call }
  end

  def ProcStack.sleep(time)
    if time < 0
      NegativeProc.new { Kernel.sleep(time.abs) }
    else
      Proc.new { Kernel.sleep(time) }
    end
  end
end

class Proc
  def + code
    ProcStack.new(self) + code
  end
end

# should print something like "chunky ... bacon\hooray for foxes"
STDOUT.sync = 1
whee = proc { print "bacon\n" } + ProcStack.sleep(-2) + proc { print "chunky " } +
       ProcStack.sleep(1) +
       proc { print "hooray for " } + proc { print "foxes" }
whee.call
