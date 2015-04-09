class ChessPos
   attr_reader :pos

   def initialize(str)
      unless str.size==2 && (?a..?h).include?(str[0]) && (?1..?8).include?(str[1])
         raise "#{str} is not a valid chess position"
      end
      @pos=str
   end

   def move(x, y)
      ChessPos.new((pos[0]+x).chr+(pos[1]+y).chr)
   end

   def hash; pos.hash; end
   def eql?(other); pos.eql?(other.pos) rescue false; end
   alias :== :eql?
end

def all_knight_moves_from(pos)
   [-2, -1, 1, 2].each { |x|
      yt=3-x.abs
      [-yt, yt].each { |y|
         np=(pos.move(x, y) rescue nil)
         yield np if np
      }
   }
end

def find_path(start, endp, forbidden={})
   # simplified dijkstra
   # all weights are equal -> no sorting
   return [] if start==endp
   pre=forbidden.merge({start=>nil})
   (front=[start]).each { |pos|
      all_knight_moves_from(pos) { |m|
         unless pre.has_key? m # if not visited before
            pre[m]=pos
            front << m
            if (endp==m) # path found
               path=[endp]
               path.unshift(pos) until start==(pos=pre[path[0]])
               return path
            end
         end
      }
   }
   nil
end

def main(s, e, *forb)
   forbidden={}
   forb.each { |f| forbidden[ChessPos.new(f)]=nil } # all keys are forbidden
   if path=find_path(ChessPos.new(s), ChessPos.new(e), forbidden)
      puts "[ #{path.collect { |p| p.pos }.join(", ")} ]"
   else
      puts nil
   end
end

main(*ARGV) rescue puts $!.message
