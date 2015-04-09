require 'enumerator'

# I suppose someone would think I should use a heap here.
# I've found that the built-in sort method is much faster
# than any heap implementation in ruby.  As a plus, the logic
# is easier to follow.
class PriorityQueue
  def initialize
    @list = []
  end
  def add(priority, item)
    # Add @list.length so that sort is always using Fixnum comparisons,
    # which should be fast, rather than whatever is comparison on `item'
    @list << [priority, @list.length, item]
    @list.sort!
    self
  end
  def <<(pritem)
    add(*pritem)
  end
  def next
    @list.shift[2]
  end
  def empty?
    @list.empty?
  end
end

class Astar
  def do_quiz_solution(puzzle)
    @terrain = []
    instr = ""
    puzzle.each {|rowstr|
      next if rowstr =~ /^\s*$/
      rowstr.gsub!(/[^.@~X*^]/,'')
      instr += rowstr
      instr += "\n"
      row = []
      rowstr.scan(/[.@~X*^]/) {|terrain|
        case terrain
        when /[.@X]/; row << 1
        when /[*]/;   row << 2
        when /\^/;    row << 3
        when /~/;     row << nil
        end
      }
      xind = rowstr.index('X')
      aind = rowstr.index('@')
      if (aind)
        @start = [@terrain.length, aind]
      end
      if (xind)
        @goal = [@terrain.length, xind]
      end
      @terrain << row
    }
    if do_find_path
      outarr = instr.split(/\n/)
      @path.each{|row,col| outarr[row][col]='#'}
      return outarr.join("\n")
    else
      return nil
    end
  end

  def do_find_path
    been_there = {}
    pqueue = PriorityQueue.new
    pqueue << [1,[@start,[],1]]
    while !pqueue.empty?
      spot,path_so_far,cost_so_far = pqueue.next
      next if been_there[spot]
      newpath = [path_so_far, spot]
      if (spot == @goal)
        @path = []
        newpath.flatten.each_slice(2) {|i,j| @path << [i,j]}
        return @path
      end
      been_there[spot] = 1
      spotsfrom(spot).each {|newspot|
        next if been_there[newspot]
        tcost = @terrain[newspot[0]][newspot[1]]
        newcost = cost_so_far + tcost
        pqueue << [newcost + estimate(newspot), [newspot,newpath,newcost]]
      }
    end
    return nil
  end

  def estimate(spot)
    # quiz statement version
    # (spot[0] - @goal[0]).abs + (spot[1] - @goal[1]).abs
    # my version
    [(spot[0] - @goal[0]).abs, (spot[1] - @goal[1]).abs].max
  end

  def spotsfrom(spot)
    retval = []
    vertadds = [0,1]
    horizadds = [0,1]
    if (spot[0] > 0) then vertadds << -1; end
    if (spot[1] > 0) then horizadds << -1; end
    vertadds.each{|v| horizadds.each{|h|
        if (v != 0 or h != 0) then
          ns = [spot[0]+v,spot[1]+h]
          if (@terrain[ns[0]] and @terrain[ns[0]][ns[1]]) then
            retval << ns
          end
        end
      }}
    retval
  end
end


if __FILE__ == $0
  puts Astar.new.do_quiz_solution(ARGF)
end
