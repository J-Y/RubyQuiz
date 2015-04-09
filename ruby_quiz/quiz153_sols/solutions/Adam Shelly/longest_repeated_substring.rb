class String
 #helper - counts number of matching characters.
 def matchlen other
   i=0
   other.each_byte{|b|
     break if b!=self[i]
     i+=1
   }
   i
 end
end

class Node
 def initialize start,len,tail=nil
   @i=start
   @l=len
   @h=tail ? tail : {}
 end

 def insert idx,len,matched=0
   match = @h[$STR[idx]]
   #add or expand child
   if match
     match.expand(idx,len,matched)
   else
     @h[$STR[idx]]=Node.new(idx,len)
   end
 end

 def expand idx,len,matched
   #count matching characters
   matchlen = $STR[@i,@l].matchlen($STR[idx,len])

   updateMax(idx-matched, matchlen+matched) if matchlen+matched > $max
   if matchlen < @l
     #split if partial match
     split_at(matchlen, idx,len)
   else
     #else add remainder of unmatched characters
     insert(idx+@l, len-@l, matchlen+matched)
   end
 end

 def split_at point, idx,len
   #one child contains the remainder of the original string(s)
   newchild = Node.new(@i+point,@l-point, @h)
   @h={}
   @h[$STR[@i+point]]=newchild
   #the other child has the remainder of the new str
   @h[$STR[idx+point]]=Node.new(idx+point, len-point)
   @l=point  #shorten our length
 end

 def updateMax idx,matchlen
   #if our string ends past the beginining of the match,
   #  discount the overlap
   overlap = @i+@l-idx-1
   matchlen-=overlap if overlap > 0
   if matchlen>$max
     $max = matchlen
     $maxpt = idx
   end
 end
end


$STR=ARGF.read
$max=0
$maxpt=0
slen = $STR.length
half= (slen/2.0).ceil
@root=Node.new(0,0)

#we don't have to look at any substrings longer than half the input
(0..half).each{|i|
 @root.insert(i,half)
}
#and the ones that start in the second half of the input are shorter still
(half+1..slen).each{|i|
 len = slen-i
 break if len<$max
 @root.insert(i,len)
}

puts $STR[$maxpt,$max].inspect
puts "\n#{$max} chars"
