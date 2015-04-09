require 'set'

class MazeSolver

  def solve start, finish
    visited = Set.new

    tul, tll = if start > finish
                 [(start << 1) + 4, nil]
               else
                  [(finish << 1) + 4, nil]
               end

    solve_it [[start]], finish, visited, tul, tll
  end

  def solve_it lpos, target, visited, tul, tll
    n = []
    lpos.each do |vs|
      v = vs.last
      next if tul and v > tul
      next if tll and v < tll

      return vs if v == target

      d = v << 1                      # double
      h = v >> 1 unless (v & 1) == 1  # half
      p2 = v + 2                      # plus 2

      n << (vs.clone << d) if visited.add? d
      n << (vs.clone << h) if h and visited.add? h
      n << (vs.clone << p2) if visited.add? p2
    end

    return solve_it(n, target, visited,tul, tll)
  end
end

if __FILE__ == $0
  puts MazeSolver.new.solve(ARGV[0].to_i, ARGV[1].to_i).join(" ")
end
