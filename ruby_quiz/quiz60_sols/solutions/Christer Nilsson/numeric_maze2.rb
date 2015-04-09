# Optimizations introduced:
#   71.723   0%  Seconds before optimization
# a  1.938  97%  Start with the larger number
# b  1.642  18%  Refactor enqueue/handle_num_maze
# c  1.533   7%  Make code inline. Eleven defs removed 
# d  1.052  31%  Skip the Struct. No need to keep track of dist
# e  0.441  58%  Use pop/unshift instead of shift/push
# f  0.371  16%  Make route an Array instead of a Hash

class Integer
  def enqueue(job)
    return if !@@route[job].nil?
    @@route[job] = self 
    @@queue.clear if job == @@target
    @@queue.unshift job if job <= @@max 
  end
  def path() [self] + (self == @@source ? [] : @@route[self].path) end
end

def solve number,target
  number > target ? solver(number,target,2) : solver(target,number,-2).reverse
end

def solver(source, target, adder)
  @@source = source
  @@target = target
  @@route = []
  @@queue = [source]
  @@max = 2 + 2 * [source, target].max
  @@route[source] = nil
  while (job = @@queue.pop ) != target
    job.enqueue(job * 2)
    job.enqueue(job / 2) if job[0] == 0 
    job.enqueue(job + adder)
  end
  target.path
end

# Original code by Kero:
class Integer
  def even?
    self[0] == 0
  end

  def odd?
    self[0] == 1
  end

  def halve
    self / 2  if self.even?
  end

  def double
    self * 2
  end

  # add inverse for add_two (we're doing DynProg)
  def sub2
    self - 2
  end

  Step = Struct.new(:dist, :next)

  def self.source; @@source; end
  def self.route; @@route; end
  def self.queue; @@queue; end

  def source; @@source; end
  def route; @@route; end
  def queue; @@queue; end

  def self.solve(source, target)
    raise ArgumentError.new("Can't solve from >=0 to <0")  if target < 0 and source >= 0
    raise ArgumentError.new("Can't solve from >0 to 0")  if target <= 0 and source > 0 
    @@source = source
    @@route = {}
    @@queue = []
    @@max = [(source + 2) * 2, target * 2].max
    # @@max = [source, target].max << 2  # and other attempts
    queue << target
    route[target] = Step.new(0, nil)
    while (job = queue.shift) != source
      job.handle_num_maze
    end

    result = [source]
    step = source
    while step != target
      step = route[step].next
      result << step
    end
    result
  end

  def enqueue(job)
    # optimization 1, do not go through pending searches when effectively done
    queue.clear  if job == source

    # optimization 2, do not look for solutions where it is not necessary
    queue << job  if job <= @@max
  end

  def handle_num_maze
    if route[double].nil? or route[self].dist + 1 < route[double].dist
      route[double] = Step.new(route[self].dist+1, self)
      enqueue double
    end
    # mind the extra check on existence of #halve 
    if halve and (route[halve].nil? or route[self].dist + 1 < route[halve].dist)
      route[halve] = Step.new(route[self].dist+1, self)
      enqueue halve
    end
    if route[sub2].nil? or route[self].dist + 1 < route[sub2].dist 
      route[sub2] = Step.new(route[self].dist+1, self)
      enqueue sub2
    end
  end
end

p Integer.solve_num_maze(ARGV[0].to_i, ARGV[1].to_i)
