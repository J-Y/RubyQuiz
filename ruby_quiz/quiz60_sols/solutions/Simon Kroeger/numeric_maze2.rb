require 'set'

def find_path from, to
  pathf = ''.ljust([from + 2, to + 2].max * 2, 'X')
  pathb = pathf.dup
  pathf[from] = ?F
  pathb[to] = ?F

  forward, backward, newbees = [from], [to], []

  loop do
    forward.each do |n|
      pathf[newbees.push(n + 2).last] = ?S if pathf[n+2] == ?X
      pathf[newbees.push(n + n).last] = ?D if pathf[n+n] == ?X
      pathf[newbees.push(n / 2).last] = ?M if (n%2) == 0 && pathf[n/2] == ?X
    end	
    forward, newbees = newbees, []
    forward.each {|n|return pathf, pathb, n if pathb[n]  != ?X}

    backward.each do |n|
      pathb[newbees.push(n - 2).last] = ?A if n > 1 && pathb[n-2] == ?X
      pathb[newbees.push(n + n).last] = ?D if pathb[n+n] == ?X
      pathb[newbees.push(n / 2).last] = ?M if (n % 2) == 0 && pathb[n/2] == ?X
    end	
    backward, newbees = newbees, []
    backward.each {|n|return pathf, pathb, n if pathf[n]  != ?X}
  end
end

def solve from, to
  return nil if from < 0 || to <= 0
  return [from] if from == to
  pathf, pathb, n = find_path(from, to)

  result = [n]
  [pathf, pathb].each do |path|
    loop do
      case path[result.last]
        when ?A then result << result.last + 2
        when ?S then result << result.last - 2
        when ?D then result << result.last / 2
        when ?M then result << result.last * 2
        else break
      end
    end
    result.reverse!
  end
  result.reverse
end

from, to = (ARGV.shift || 868056).to_i, (ARGV.shift || 651040).to_i

t = Time.now
p solve(from, to)
puts "Time: #{Time.now - t}"
