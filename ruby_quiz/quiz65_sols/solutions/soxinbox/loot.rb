#booty
class Array
  def sum
    inject(0){|v,e| v += e.to_i}
  end
end
class PileOfBooty
  attr :sum
  def initialize
    @sum = 0
    @pile = []
  end
  def add(i)
    @sum += i.to_i
    @pile << i.to_i
  end
  def rem
    r = @pile.pop
    @sum -= r
    r
  end
  def sort!
    @pile.sort!
  end
end

def sumit(piles,treasure,divy)
  if treasure.sum == 0
    return piles
  else
    ruby = treasure.rem
    piles.size.times{|i|    #try adding the ruby to each pirate's pile in turn
      piles[i].add ruby  #add the ruby to the this pile
      if piles[i].sum <= divy and sumit(piles,treasure,divy) != nil
        return (piles)  #that worked ok, now divy up the rest of the booty
      else
        piles[i].rem    #that didn't work, take the ruby back
      end
    }
    treasure.add ruby   #couldn't find a soultion from here, put the ruby back in the booty pile and return nil
    return nil
  end
end
def dumpit ( piles,n )
    print "\n\n"
  if piles == nil
    print "It bees not possible to divy the booty amongst #{n} pirates, ARRRGH!\n"
  else
    piles.each_index{|i|
      piles[i].sort!
      print "#{i}:"
      print " #{piles[i].rem}" while piles[i].sum != 0
      print "\n"
    }
  end
end

n=ARGV.shift.to_i              #number of pirates
treasure = PileOfBooty.new
ARGV.each{|e| treasure.add e}   #collection of rubys to divy up
divy = treasure.sum/n          #each pirate's share
piles = []
n.times{piles << PileOfBooty.new} #a pile of booty for each pirate
dumpit( sumit(piles,treasure,divy) ,n)
