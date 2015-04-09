#!/usr/bin/ruby

class Array
  def uniquepush(num)
    self.push(num) if (self.assoc(num[0]) == nil)
  end
end

def interpret(val, solution)
  returnval = "[" + val.to_s
  solution[1].each{|step|
    val = val/2 if (step == 0)
    val = val+2 if (step == 1)
    val = val*2 if (step == 2)
    returnval += "," + val.to_s
  }
  returnval += "]"
end

def solve(initial, target)
  queue = [[initial, Array.new]]
  solution = queue.detect{|step|
    if (step[0] == target)
      true
    else
      queue.uniquepush([step[0]/2, step[1].clone().push(0)]) if (step[0] % 2 == 0 && step[1].last != 2)
      queue.uniquepush([step[0]+2, step[1].clone().push(1)])
      queue.uniquepush([step[0]*2, step[1].clone().push(2)]) if (step[1].last != 0)
      false
    end
  }
  interpret(initial, solution)
end

puts solve(ARGV[0].to_i, ARGV[1].to_i)
