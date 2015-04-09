require 'enumerator'
require 'grid'

def distance(p1,p2,sqrt=true)
  dist=((p1[0]-p2[0])**2 +(p1[1]-p2[1])**2)
  sqrt ? Math::sqrt(dist) : dist
end

def length(path, sqrt=true)
  len=distance(path[0],path[-1],sqrt)
  path.each_cons(2) {|p1,p2| len+=distance(p1,p2,sqrt)}
  len
end

def mutation(path,i)
  len=path.length
  rev=i%(len/2)+2
  shift=rand(len-1)
  pos=rand(len-rev)
  newpts=path[shift..-1]+path[0...shift]
  newpts[pos,rev]=newpts[pos,rev].reverse
  newpts
end

num,pct=ARGV
num||=5
pct||=0
num=num.to_i
pct=pct.to_i

grid=Grid.new(num)
pass=grid.min+grid.min*pct/100.0+0.1
pathset=[grid.pts]
count=0
while (length(pathset[0])>pass) do
  count+=1
  newpaths=[]
  sample=(count**1.5).round
  pathset.each { |path| sample.times {|i| newpaths << mutation(path,i)} }
  pathset=(pathset+newpaths).sort_by { |path| length(path,false) }.first(sample)
  puts "#{count}. #{length(pathset[0])}"
end
p pathset[0]
