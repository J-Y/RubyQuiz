#!ruby

# First, we need a way to convert integers into English.
# Fortunately, that was quiz #25, so I just stole one of
# the many solutions offered there.
#
# More commentary after the swiped code

# stolen from Glenn Parker's solution to ruby
# quiz #25. [ruby-talk:135449]

# Begin swiped code
class Integer

   Ones = %w[ zero one two three four five six seven eight nine ]
   Teen = %w[ ten eleven twelve thirteen fourteen fifteen
              sixteen seventeen eighteen nineteen ]
   Tens = %w[ zero ten twenty thirty forty fifty
              sixty seventy eighty ninety ]
   Mega = %w[ none thousand million billion ]

   def to_en
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
# End swiped code

# Okay, now on with my solution.  I assume that almost every
# solution will use some form of the "Robbinsoning" described
# in the pangram page linked from the quiz.  This somewhat limits
# the number of different variations we can have.
#
# In my solution, I was trying something a bit tricky with how I
# represented letter frequency to speed things up - though I still
# think that there's some slight twist to the search scheme that
# makes things even faster.  Hopefully I'll find out by examining
# others' solutions.
#
# I represented the letter frequencies of letters in a sentence
# as one huge bignum, such that if "freq" was a variable containing
# the number, then "freq & 0xFF" would be the number of "a"s in the
# sentence, "(freq>>8) & 0xFF" would be the number of "b"s, etc.
#
# This means that when I adjust a guess, changing the actual frequency
# is as simple as adding and subtracting from a single variable.
#
# I probably could have split this up some, but the option of writing
# Hash.new to get the equivalent of a memoized lambda made it really
# easy to simply write it as one big routine.
#
# One last thing - note when I take a random step towards the actual
# frequency, I actually call rand twice, and take the larger value.
# I found this to be about twice as fast as calling rand just once.
# (This biases things towards larger steps; i.e. towards the actual
# measured frequency)

# This routine is for debugging - it turns a bignum containing
# letter frequencies into a human-readable string.
def explode(big)
  s = ""
  ('a'..'z').each{|x| big, r = big.divmod(256); s += "%2d " % r}
  s
end

def find_sentence(prefix, suffix, initial = {})
  letterre = Regexp.new('(?i:[a-z])');
  letters = ('a'..'z').to_a
  letterpower = Hash.new {|h,k| h[k] = 1 << ((k[0]-?a)*8)}
  lettershifts = letters.map {|x| ((x[0]-?a)*8)}
  basesentence = prefix + letters.map {|x|
    (x == 'z'? 'and ' : '') + "_ '#{x}'"}.join(', ') + suffix
  basefreq = 0
  basesentence.scan(letterre) {|x| basefreq += letterpower[x.downcase]}
  # enfreq holds the letter counts that spelling out that number adds to
  # the sentence.
  # E.g. enfreq[1] == letterpower['o'] + letterpower['n'] + letterpower['e']
  enfreq = Hash.new {|h,k|
    if k > 255 then
      h[k] = h[k >> 8]
    else
      h[k] = 0
      k.to_en.scan(letterre) {|x| h[k] += letterpower[x.downcase]}
      h[k] += letterpower['s'] if k != 1
    end
    h[k]
  }
  guessfreq = 0
  letters.each{|x|
    guessfreq += (initial[x]||0) * letterpower[x]
  }
  guessfreq = basefreq if guessfreq == 0
  actualfreq = 0
  sentence = ""
  begin
    cyclecount, adjusts = 0, 0
    until guessfreq == actualfreq do
      if actualfreq > 0 then
        lettershifts.each{ |y|
          g = 0xFF & (guessfreq >> y)
          a = 0xFF & (actualfreq >> y)
          if (g != a)
            d = (g-a).abs
            r1 = rand(d+1)
            r2 = rand(d+1)
            r1=r2 if r1 < r2
            r1=-r1 if a<g
            if (r1 != 0) then
              adjusts += 1
              guessfreq += r1 << y
              actualfreq += enfreq[g+r1] - enfreq[g]
            end
          end
        }
      else
        actualfreq = basefreq
        lettershifts.each {|y| 
          g = 0xFF & (guessfreq >> y)
          actualfreq += enfreq[g]
        }
      end
#DEBUG
#      puts explode(actualfreq)
#      return "___" if cyclecount > 10_000_000
      cyclecount += 1
    end
  ensure
    puts [cyclecount, adjusts].inspect
  end
  sentence = prefix + ('a'..'z').map {|x|
    g = (guessfreq >> ((x[0]-?a)*8))%256
    (x == 'z'? 'and ' : '') + "#{g.to_en} '#{x}'" +
    (g==1 ? '' : 's')}.join(', ') + suffix
  sentence
end

# And here's where I actually call it.  Note that I *cannot* get an
# answer if I use the prefix that contains my email address.

puts find_sentence(
#  "a ruby quiz solution found this sentence enumerating ",
#  "The program from martin@snowplow.org produced a sentence with ", 
  "Daniel Martin's sallowsgram program produced a sentence with ",
#  "This terribly inefficient pangram contains ",
#  "Darren's ruby panagram program found this sentence which contains exactly ",
  "."
  # optional seed value - this is the same as the sentence given
  # in the quiz description.
  #  {'a'=>9,'b'=>2,'c'=>5,'d'=>4,'e'=>35,
  #  'f'=>9,'g'=>3,'h'=>9,'i'=>16,'j'=>1,
  #  'k'=>1,'l'=>2,'m'=>3,'n'=>27,'o'=>14,
  #  'p'=>3,'q'=>1,'r'=>15,'s'=>34,'t'=>22,
  #  'u'=>6,'v'=>6,'w'=>7,'x'=>6,'y'=>7,
  #  'z'=>1}
  )
