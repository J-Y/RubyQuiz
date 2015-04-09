class Tournament
 attr_reader :list

 def initialize players
   raise "Must be more than one player in the tournament!" if players < 2
   @players = players
   @list = Array.new(players) { |i| i+1 }

   # Add 'bye's up to the next power of 2
   next_power = 2 ** sprintf("%b",players).length
   unless players == next_power / 2
     (players+1).upto(next_power) { @list << 'bye' }
   end
   @list = generate @list
 end

 def generate list
   len = list.length
   return list if len <= 2
   left = list[0..(len/4-1)]+list[-(len/4)..-1]
   right= list[(len/4)..-(len/4+1)]
   [generate(left),generate(right)]
 end

 def to_s
   lines = []
   depth = sprintf("%b",@list.flatten.length).length - 1
   title = ""
   1.upto(depth) { |r| title += sprintf( "R%d  ", r ) }
   lines << title
   lines << ("=" * title.length)
   lines << to_a(@list)
   lines.join("\n")
 end

 # recursively build the tree display
 def to_a list = @list
   lines = []
   return lines if list.length < 2
   if list[0].is_a? Array
     left  = to_a(list[0]).flatten
     right = to_a(list[1]).flatten
     indent = (left + right).collect { |i| i.length }.max
     all = left[0..(left.length / 2)]
     left[(left.length / 2 + 1)..-1].each do |i|
       all << ((i + (" "*indent))[0..(indent-1)] + "|")
     end
     all << (" "*indent) + "|---"
     right[0..(right.length / 2 - 1)].each do |i|
       all << ((i + (" "*indent))[0..(indent-1)] + "|")
     end
     all << right[(right.length / 2)..-1]
   else
     return [list[0].to_s, "---", "   |---", "---", list[1].to_s]
   end
 end
end
