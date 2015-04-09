#!/usr/bin/env ruby


require 'test/unit'
require 'rubyquiz73'

# You must insert your email address as <youremail> in this method call!
DiGraph = RubyQuiz73.class_under_test("hchoudh@gmail.com")

class DiGraph
    @path_strs
    def equal?(g)
        if (g.size != self.size)
            return false
        end
        # XXX: Must be better way to initialize @path_strs. Perhaps using initialize method?
        if (not @path_strs)
            g_str = self.to_s
            @paths_strs = Hash.new
            g_arr = g_str.split(/[,\[\]]/)
            g_arr.shift
            g_arr.each do |s|
                s.strip!
                @paths_strs[s] = 1
            end
        end

        g_str = g.to_s
        g_arr = g_str.split(/[,\[\]]/)
        g_arr.shift
        g_arr.each do |s|
            s.strip!
            if (not @paths_strs[s])
                return false
            end
        end
        return true 
    end
end

class TestDiGraph < Test::Unit::TestCase
    def test_01_digraph_creation
        dg1 = DiGraph.new
        assert_kind_of(DiGraph, dg1)
        assert_equal(0, dg1.size)
    end

    def test_02_size
        dg2 = DiGraph.new([1,2], [2,3])
        assert_equal(3, dg2.size)
        assert_equal(2, dg2.num_edges)
    end

    # Add/write your own tests here...

    # @dg is the generated DiGraph. Store the paths in a hash called @paths
    @dg
    # @paths is a hash. Each element of the hash is an array that contains all the paths 
    # from that node
    @paths
    # @nodes is an array which contains a list of all the nodes
    @nodes

    # Randomly generate @dg and the corresponding @paths
    def generate_dg
        nodes = Array.new
        # 10 nodes total
        10.times do 
            nodes << rand(10)
        end
        nodes.uniq!
        @paths = Hash.new
        nodes.each do |n|
            num_paths_from_each_node = rand(3) + 1
            next_nodes = Array.new
            num_paths_from_each_node.times do
                next_nodes << nodes[rand(nodes.length)]
            end
            next_nodes.uniq!
            @paths[n] = next_nodes
        end
        arr = Array.new
        @paths.each do |key,vals|
            @paths[key].each do |val|
                arr << [key,val]
            end
        end
        @dg = DiGraph.new(*arr)
        @nodes = @paths.keys
    end

    # Depth first search for the longest simple path starting from 'node'
    # Simple path means a path that doesn't contain any duplicate edges
    # Note: I'm not suing the definition of simply connected based on no duplicate nodes
    def search(node)
        longest_path = 0
        if (@paths[node])
            @paths[node].each_index do |next_idx|
                next_node = @paths[node][next_idx]
                @paths[node].delete_at(next_idx)
                tmp = 1 + search(next_node)
                @paths[node].insert(next_idx,next_node)
                if (longest_path < tmp)
                    longest_path = tmp
                end
            end
        end
        return longest_path
    end

    def find(start,last)
        next_nodes = Array.new
        next_nodes << start
        visited = {}
        while (not next_nodes.empty?)
            next_node = next_nodes.shift
            next if visited[next_node]
            visited[next_node] = true
            return true if next_node == last
            @paths[next_node].map do |x| next_nodes << x end
        end
        return false
    end

    # Flood fill to find the largest strongly connected component starting from node
    # Strongly connected means that there is a path from u->v and from v->u
    # Paths does not mean edges. Paths could have multiple edges
    def fill(node)
        filled_so_far = Array.new
        nodes_hash = Hash.new
        already_seen = Hash.new
        queue = [node]
        while (not queue.empty?)
            next_node = queue.shift
            next if already_seen[next_node]
            already_seen[next_node] = true
            @paths[next_node].each do |next_next_node|
                if (next_next_node == next_node)
                    # special case. we consider a node connected to itself to be strongly connected
                    nodes_hash[next_node] = true
                elsif (find(next_next_node,next_node)) 
                    # make sure there is a reverse path
                    queue << next_next_node
                    nodes_hash[next_node] = true
                    nodes_hash[next_next_node] = true
                end
            end
        end
        nodes = nodes_hash.keys
        @paths.each do |k,v|
            if nodes.include?(k)
                v.each do |v|
                    if nodes.include?(v)
                        filled_so_far << [k,v]
                    end
                end
            end
        end
        return filled_so_far
    end

    def test_03_max_length_of_simple_path_including_node
        generate_dg
        @nodes.each do |node|
            longest_path = search(node)
#            if (longest_path != @dg.max_length_of_simple_path_including_node(node))
#                puts "test_03 failed..."
#                puts "DiGraph  => #{@dg.to_s}"
#                puts "node     => #{node}"
#                puts "expected => #{longest_path}"
#                puts "received => #{@dg.max_length_of_simple_path_including_node(node)}"
#            end
            assert_equal(longest_path,@dg.max_length_of_simple_path_including_node(node))
        end
    end

    def test_04_strongly_connected_component_including_node
        generate_dg
        @nodes.each do |node|
            filled_dg = DiGraph.new(*fill(node))
            received_dg = @dg.strongly_connected_component_including_node(node)
#           if (not filled_dg.equal?(received_dg))
#               puts "test_04 failed..."
#               puts "DiGraph  => #{@dg.to_s}"
#               puts "node     => #{node}"
#               puts "expected => #{filled_dg.to_s}"
#               puts "received => #{received_dg.to_s}"
#           end
            assert_equal(true,filled_dg.equal?(received_dg))
        end
    end
end


