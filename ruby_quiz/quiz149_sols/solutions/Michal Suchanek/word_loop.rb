def indexes l, i
 res = []
 ptr = 0
 while (ptr = l.index i, ptr)
   res << ptr
   ptr+=1
 end
 res
end
# .
#.c1=c5..c2
# .       .
# c4.....c3
def draw_loop word, c1, c5
 length = (c5 - c1) -4
 width = length/4
 height = length/2 - width
 word = word[0..0].upcase + word[1..-1]
 c2 = c1 + width +1
 c3 = c2 + height +1
 c4 = c3 + width +1
 word[(c5+1)..-1].reverse.scan(/./).map{|c| " "*c1 + c + "\n"}.join +
   word[0..c2] + "\n" +
   (1..height).map{|i| " "*c1 + word[c5 - i].chr + " "*width + word[c2 + i].chr + "\n"}.join +
   " "*c1 + word[c3..c4].reverse + "\n"
end
def wloop word
 word=word.downcase
 tried=[]
 ptr=0
 while ptr < word.length
   if tried.include? word[ptr]
     ptr+=1
     next
   end
   char = word[ptr]
   tried << char
   pos = indexes word, char
   next unless pos.length > 1
   i, j = 0
   while i < pos.length - 1
     j=pos.length - 1
     while j > i
       diff = pos[j] - pos[i]
       if (diff)>=4 && (diff) % 2 == 0
         return draw_loop word, pos[i], pos[j]
       end
       j-=1
     end
     i+=1
   end
   ptr += 1
 end
 "No loop \n"
end
