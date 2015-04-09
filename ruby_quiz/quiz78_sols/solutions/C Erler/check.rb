# Determines whether a packing diagram is acceptable.
def good_diagram? packing_diagram
 # Ensure there is no packaging that surrounds no items: (()B)
 return false if packing_diagram =~ /\(\)|\[\]|\{\}/

 # Make an unfrozen copy of the original.
 packing_diagram = packing_diagram.dup

 # Remove the items: (((B))(B)(B)) -> ((())()())
 packing_diagram = packing_diagram.delete 'B'

 # Repeatedly remove matching opening-closing neighbors: ((())()()) -> (()) -> () ->
 packing_diagram.gsub! /\(\)|\[\]|\{\}/, '' while packing_diagram =~ /\(\)|\[\]|\{\}/

 # If everything was removed, the diagram was good.
 packing_diagram.empty?
end

packing_diagram = ARGV.join ' '
exit 1 unless good_diagram? packing_diagram
puts packing_diagram
exit 0
