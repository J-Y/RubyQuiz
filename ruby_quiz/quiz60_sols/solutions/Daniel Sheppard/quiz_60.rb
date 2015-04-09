require 'dijkstra'

class Integer
    include SimpleDijkstra
    def each_neighbour
        yield(self + 2)
        yield(self << 1)
        yield(self >> 1) if(self[0] == 0)
    end  
end

def solve(start_node, end_node)
    #~ MyInteger.new(start_node,end_node).shortest_path(end_node)
    #~ $max = end_node * 2
    start_node.shortest_path(end_node)
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
