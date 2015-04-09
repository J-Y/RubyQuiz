require 'rubygems'
require 'priority_queue'

Infinity = 1/0.0

def solve(start_node, end_node)
    return [start_node] if start_node == end_node
    active = PriorityQueue.new
    distances = Hash.new { Infinity }
    parents = Hash.new
    active[start_node] = 0
    until active.empty?
        u, distance = active.delete_min
        distances[u] = distance
        d = distance + 1
	neighbours = [u << 1, u + 2]
	neighbours << (u >> 1) if u[0] == 0
        neighbours.each do |v|
            next unless d < distances[v]
	    active[v] = distances[v] = d
	    parents[v] = u
	    if(v == end_node)
	        path = [v]
		while v = parents[v]
			path.unshift(v)
		end
		return path
            end
	end
    end
    raise "No Path Found"
end

#~ p solve(2, 9)
#p solve(9, 2)


#~ require 'benchmark'
#~ Benchmark.bm {|bm|
    #~ bm.report {1000.times { solve(2,9)}}
    #~ bm.report {1000.times { solve(2,9)}}
#~ }    

if(__FILE__ == $0)
    if(ARGV.size == 2)
        src, dest = *ARGV.map {|x| x.to_i}
        puts solve(src, dest)
    else
        puts "Usage: #{$0} start end"
    end
end
