#this is my first solution
#a turtle graphics file for use with any solution to Quiz 104

#shows the whole fractal for 0<=DEPTH<=4
#shows part of the fractal for 5<=DEPTH

DEPTH=(ARGV[1] or 3).to_i

def segment n
   if n==0
      fd [(360/(3**DEPTH)),3].max
   else
      segment n-1
      lt 90
      segment n-1
      rt 90
      segment n-1
      rt 90
      segment n-1
      lt 90
      segment n-1
   end
end

#get into a sensible home position
bk 180
rt 90
bk 180
pd
#actually draw the fractal
segment DEPTH
