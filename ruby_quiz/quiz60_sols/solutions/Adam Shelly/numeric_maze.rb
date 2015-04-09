class NumericMazeSolver
  #the allowable operations - changing the order changes the solution
  #this order favors smaller numbers
  OPS = {:FWD=>[:halve, :add2,:double],:REV=>[:double, :sub2,:halve]}
  #create a hash mapping operations to their inverse.
  ANTIOP=OPS[:FWD].zip(OPS[:REV]).inject({}){|h,s|h[s[0]]=s[1];h[s[1]]=s[0];h}

  #change this line to solve Quiz60B
  #COST = {:halve=>1, :add2=>1, :double=>1,:sub2=>1}
  COST = {:halve=>4, :add2=>1, :double=>2,:sub2=>1}

  def initialize(noisy=false)
    @noisy = noisy
  end

  # a Trail holds a set of operations
  class Trail
    attr_reader :path,:dir,:cost
    def initialize direction, value=nil, path=[], cost = nil
      @dir =direction
      @path = path
      @path.push value if value
      @cost = if cost && value
        cost + calc_cost(value)
      else
        path.inject(0){|sum,op| c=calc_cost(op); sum+=c if c; sum}
      end
    end

    def grow operation
      return Trail.new(@dir,operation,@path.dup,@cost)
    end
    def inspect
      s=@path.inject("$#{@cost}:"){|s,v| s+"#{v}->"}
      s[0..-3]
    end
    def invert
      Trail.new(@dir, nil, @path.reverse.map{|v| ANTIOP[v] || v},@cost)
    end
    def calc_cost operation
      @dir == :FWD ? COST[operation] : COST[ANTIOP[operation]]
    end
  end

  #the operations
  def double a
    return a*2
  end
  def halve a
    return a/2 if a%2==0
  end
  def add2 a
    return a+2
  end
  def sub2 a
    return a-2
  end

  #store the cheapest trail to each number in the solution hash
  def expand(val)
      trail = @sset[val]
      OPS[trail.dir ].each do |op|
        result= self.send(op,val)
        if result
          newpath = trail.grow(op)
          if (foundpath = @sset[result] )
            if foundpath.dir != newpath.dir
              cost = foundpath.cost+newpath.cost
              @match= [newpath,result, cost] if (!@match || (cost < @match.last))
            elsif foundpath.cost > newpath.cost
              @sset[result] = newpath
            end
          else
            @sset[result] = newpath
            if (!@match || (newpath.cost+@depth) < @match.last)
              @newvals.push(result)  #only check if total cost can be less than match cost
            end
          end
        end
      end
  end



  def solve(start,target)
    return nil if start<0 || target < 1
    return [start] if start==target
    @sset = {start=>Trail.new(:FWD,start) ,
                   target=>Trail.new(:REV,target) }
    @newvals=[start,target]
    solution = nil
    @match=nil
    @depth=0
    while true do
      val = @newvals.shift
      break if !val
      expand(val)
      @depth+=1
    end
    trail, matchnum = solution
    trail, matchnum = @match
    if trail.dir == :FWD
      first,last = trail,@sset[matchnum].invert
    else
      first,last = @sset[matchnum],trail.invert
    end
#    p first,last
    get_solution(first,last)
  end

  def get_solution(first,last)
    puts "SOLUTION = " + first.inspect + "->" + last.inspect  if @noisy
    p = first.path + last.path
    s=[p.shift]
    p.each{ |v| s << self.send(v,s[-1]) unless v.is_a? Integer}
    s
  end

end

if __FILE__ == $0
  start, goal, is_noisy = ARGV[0].to_i, ARGV[1].to_i, ARGV[2]!=nil
  puts "usage: @$0 start goal [noisy]" unless start && goal
  p NumericMazeSolver.new(is_noisy).solve(start, goal)
end
