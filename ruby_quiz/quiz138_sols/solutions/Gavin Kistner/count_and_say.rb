# Solution to Ruby Quiz #138 by Gavin Kistner
SEED = "LOOK AND SAY"

module Enumerable
  def item_counts
    inject( Hash.new(0) ){ |counts, item|
      counts[ item ] += 1
      counts
    }
  end
end

class String
  def look_and_say
    counts = upcase.scan( /[A-Z]/ ).item_counts
    counts.keys.sort.map{ |letter|
      "#{counts[letter].to_english.upcase} #{letter}"
    }.join( ' ' )
  end
end

# Code courtesy of Glenn Parker in Ruby Quiz #25
class Integer
   Ones = %w[ zero one two three four five six seven eight nine ]
   Teen = %w[ ten eleven twelve thirteen fourteen fifteen sixteen
              seventeen eighteen nineteen ]
   Tens = %w[ zero ten twenty thirty forty fifty sixty seventy eighty ninety ]
   Mega = %w[ none thousand million billion trillion quadrillion
              quintillion sextillion septillion octillion ]
   def to_english
     places = to_s.split(//).collect {|s| s.to_i}.reverse
     name = []
     ((places.length + 2) / 3).times do |p|
       strings = Integer.trio(places[p * 3, 3])
       name.push(Mega[p]) if strings.length > 0 and p > 0
       name += strings
     end
     name.push(Ones[0]) unless name.length > 0
     name.reverse.join(" ")
   end
   private
     def Integer.trio(places)
       strings = []
       if places[1] == 1
         strings.push(Teen[places[0]])
       elsif places[1] and places[1] > 0
         strings.push(places[0] == 0 ? Tens[places[1]] :
                      "#{Tens[places[1]]}-#{Ones[places[0]]}")
       elsif places[0] > 0
         strings.push(Ones[places[0]])
       end
       if places[2] and places[2] > 0
         strings.push("hundred", Ones[places[2]])
       end
       strings
    end
end

str = SEED
strs_seen = {}
0.upto( 9999 ){ |i|
  puts "%4d. %s" % [ i, str ]
  if last_seen_on = strs_seen[ str ]
    print "Cycle from #{i-1} back to #{last_seen_on}"
    puts  " (#{i - last_seen_on} lines in cycle)"
    break
  else
    strs_seen[ str ] = i
  end
  str = str.look_and_say
}
