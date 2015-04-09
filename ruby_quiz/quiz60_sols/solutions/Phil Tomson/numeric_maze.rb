class Integer
  def odd?
    self%2 == 1
  end

  def even?
    self%2 == 0
  end
end

class Value
  include Comparable
  attr_reader :value
  attr_reader :ops
  def initialize val
    @value = val
    @ops   = [:double, :add_two, :halve]
  end

  def <=> other
    case other
    when Value
      @value <=> other.value
    when Numeric
      @value <=> other
    end
  end

  def has_ops?
    ! @ops.empty?
  end

  def next_op
    @ops.pop
  end

  def each_op
    @ops.each {|op|
      yield op
    }
  end

  def do_op op
    self.send op
  end

  #ops
  def double 
    @value*2
  end

  def halve 
    @value/2
  end

  def add_two 
    @value+2
  end

  def to_s
    @value.to_s
  end

  def to_i
    @value.to_i
  end

end

class NumMazeSolver
  MAX_DEPTH = 20
  attr_reader :solution
  def initialize(start, finish)
    @start,@finish = start,finish
    @val_list     = []
    @solution     = nil

    # Set max value that a given solution will contain:
    # -> if the finish value is the largest there is no need to go
    # beyond finish*2 in any search
    # -> if the start value is the largest there is no need to go
    # beyond start*3 in any search:
    @largest      = finish > start ? finish*2+2 : start*3

    #NOTE: max_depth should be dynamic:
    #either:
    #1) it should be increased if a solution was not found(and employ memoization)
    #2) it should be determined mathematically from the absolute difference of
    #   start and finish (I suspect this would be possible, just not sure how
    #   to do it - there must be a theorem somewhere (?))
    @max_depth     = MAX_DEPTH
  end

  def solve start=@start, finish=@finish
    #handle the trivial case:
    if start == finish
      @solution = [start]
      return
    end
    first = Value.new(start)
    @val_list << first
    prev_op= first.ops.last
    while !(@val_list.empty?) && @val_list.last.has_ops?
      next_op = @val_list.last.next_op
      unless (next_op == :halve && @val_list.last.to_i.odd?) || \
        (next_op == :halve && prev_op == :double) || \
        (next_op == :double && prev_op ==:halve)
        new_val = @val_list.last.send(next_op)
        #ensure there are no cycles before adding new_val to val_list:
        #NOTE: I suspect we're spending a lot of time in find
        if new_val < (@largest) && !(@val_list.find{|v| v.to_i == new_val})
          @val_list << ( Value.new(new_val) ) 
        end
        if new_val == finish
          puts "Found a solution, length is: #{@val_list.length}" if $DEBUG
          @solution ||= @val_list.clone #first time
          if @solution.size > @val_list.size
            @solution = @val_list.clone #take a snapshot
            puts "new best solution: [ #{@solution.map{|v| v.to_i}.join(",")} ] length: #{@solution.length}" if @solution && $DEBUG
          end
          dest = @val_list.pop
        end
      end
      if (@solution && @val_list.size >= @solution.size ) || @val_list.size > @max_depth
        #A solution already exists which is shorter (or max_depth reached)
        #no need to go any further on this branch, prune the search
        p = @val_list.pop
      end
      back_track #take values with empty ops off the list
      prev_op = next_op
    end #while
  end

  # back_track: clear out entries with empty ops list
  def back_track
    while @val_list.last && !@val_list.last.has_ops?
      poppedval = @val_list.pop
    end
  end

  def to_s
    @solution.map{|v| v.to_s }.join(',')
  end
end


if $0 == __FILE__
  require 'benchmark'
  include Benchmark

  bm(6) do |x|
    #s = Solver.new(2,9)
    puts "9 -> 2"
    s =NumMazeSolver.new(9,2)
    x.report("9->2") {s.solve}
    puts s.solution.map{|v| v.to_i }.join(",")
    puts "2 -> 9"
    s =NumMazeSolver.new(2,9)
    x.report("2->9") {s.solve}
    puts s.solution.map{|v| v.to_i }.join(",")
    s =NumMazeSolver.new(1,25)
    x.report("1->25") {s.solve }
    puts s.solution.map{|v| v.to_i }.join(",")

    #this one takes a while on my slow machine...
    s =NumMazeSolver.new(22,999)
    x.report("22->999") {s.solve }
    puts s.solution.map{|v| v.to_i }.join(",")
  end

end

