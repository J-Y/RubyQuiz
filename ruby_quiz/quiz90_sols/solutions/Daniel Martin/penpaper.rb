require 'narray'

n = (ARGV.first||'6').to_i
tracker = NArray.byte(n,n)
jumparray = NArray.byte(13,13,2,8)

jumppatterns = [[-2,-2],[-3,0],[-2,2],
[0,3],[2,2],[3,0],[2,-2],[0,-3]]

jumppatterns.each_with_index{|(x,y),z|
  basex,basey = 6+x,6+y
  jumparray[basex,basey,0,z]=1
  jumppatterns.each{|x2,y2|
    jumparray[basex+x2,basey+y2,1,z]=1
  }
}
zoomarray = NArray.byte(13,13)
randarray = NArray.float(8)
loopctr = 1
foundit=false
pospath=[]
while !foundit
  tracker[] = 1
  x=rand((n/2.0).ceil)
  y=0
  pospath=[[x,y]]

  while pospath.size < n*n
    tracker[x,y] = 0
    zoomarray[] = 0
    left,right,top,bottom=x-6,x+6,y-6,y+6
    left=0     if left<0
    top=0      if top<0
    right=n-1  if right>=n
    bottom=n-1 if bottom>=n
    zoomarray[left-(x-6),top-(y-6)] =
      tracker[left..right,top..bottom]
    workarr = zoomarray * jumparray
    workarr = workarr.sum(0,1)
    randarray.random!
    randarray.add!(workarr[1,true])
    j = randarray.eq(randarray[workarr[0,true]].min).where[0]
    if (randarray[j] < 1 and pospath.size < n*n-1)
      # drat.  Try again
      break
    end
    x += jumppatterns[j][0]
    y += jumppatterns[j][1]
    pospath << [x,y]
  end
  if pospath.size == n*n
    foundit = true
    puts "Found solution on trial #{loopctr}:"
    a = Array.new(n){Array.new(n){nil}}
    pospath.each_with_index{|(x,y),z| a[x][y]=z+1}
    len = 1 + (n*n).to_s.length
    puts('-' * (len*n + 2))
    a.each{|m|
      print '|'
      m.each{|s| print("%#{len}d" % s)}
      puts '|'
    }
    puts('-' * (len*n + 2))
  else
    loopctr += 1
  end
end
