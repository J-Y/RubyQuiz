#a cute little helper method to do the hard work
class Array
  def split &blk
    #split the array into little arrays at boundary where block evals to true
    i=0
    r = []
    while i<length
      start=i
      loop do
        i+=1
        break if blk.call(at(i-1), at(i))
        if i==length-1
          i+=1
          break
        end
      end
      r << slice(start..i-1)
    end
    r
  end
end

# i personally don't really see the point of wrapping this up in a class
def dayrange *args
  r = []
  days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
  args.collect!{|d| days.include?(d) ? days.index(d) : d }
  raise ArgumentError.new("invalid arguments #{args.inspect} for dayrange")
unless (args - (0..6).to_a).empty?
  args.sort.split{|a,b| a.succ != b}.each{|d|
    if d.size>=3
      r << days[d[0]] + '-' + days[d[-1]]
    else
      r.concat d.collect{|n| days[n]}
    end
    }
  r.join(',')
end

#some examples
puts dayrange(0,2,3,4,6)
puts dayrange('Mon','Tue','Wed', 'Fri')
puts dayrange(0,'Tue',2,'Sat')
puts dayrange(4,2,5,1,3)
