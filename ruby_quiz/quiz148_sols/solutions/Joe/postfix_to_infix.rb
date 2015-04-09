stack = Array.new
ARGV.first.split.each do |n|
        if n.match(/[\d\.]+/) then
                stack.push n
        else
                a,b = stack.pop,stack.pop
                stack.push "(#{b} #{n} #{a})"
        end
end

puts stack.first
