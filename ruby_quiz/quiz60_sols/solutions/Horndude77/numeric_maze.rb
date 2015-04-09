def solve(from, to)
    return [from] if from == to
    ops = []
    ops << lambda {|n| n*2}
    ops << lambda {|n| n/2 if n%2 == 0}
    ops << lambda {|n| n+2}

    invops = []
    invops << lambda {|n| n/2 if n%2 == 0}
    invops << lambda {|n| n*2}
    invops << lambda {|n| n-2}

    fromedges = {from => :start}
    toedges = {to => :start}
    fromqueue = [from]
    toqueue = [to]
    linknode = nil

    while(toqueue.length>0 && fromqueue.length>0)
        fromnode = fromqueue.shift
        tonode = toqueue.shift
        if(toedges[fromnode] || fromnode==to) then
            linknode = fromnode
            break
        elsif(fromedges[tonode] || tonode==from) then
            linknode = tonode
            break
        end

        ops.each do |o|
            val = o.call(fromnode)
            if(val && !fromedges[val] && val > 0) then
                fromedges[val] = fromnode
                fromqueue << val
            end
        end

        invops.each do |o|
            val = o.call(tonode)
            if(val && !toedges[val] && val > 0) then
                toedges[val] = tonode
                toqueue << val
            end
        end
    end

    return [] if(linknode == nil)
    chain = []
    currnode = linknode
    while(fromedges[currnode] != :start)
        chain.unshift currnode if currnode != to
        currnode = fromedges[currnode]
    end
    currnode = toedges[linknode]
    while(toedges[currnode] != :start && currnode != :start)
        chain << currnode
        currnode = toedges[currnode]
    end
    return [from]+chain+[to]
end

if ARGV.length != 2 then
    puts "usage: #{$0} <from> <to>"
    exit
end

from, to = ARGV[0].to_i, ARGV[1].to_i
if from < 1 || to < 1 then
    puts "inputs must be positive"
    exit
end
p solve(from, to)
