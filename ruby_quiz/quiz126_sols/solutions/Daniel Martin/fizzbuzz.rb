# Well, Mr. Martin, this is just a simple little question we ask all of
# our programming candidates.  Let's see what you do with "FizzBuzz":

(1..100).each{|i|
  x = ''
  x += 'Fizz' if i%3==0
  x += 'Buzz' if i%5==0
  puts(x.empty? ? i : x);
}

# Okay, very straightforward.  You know, I've never been an overly big
# fan of the question mark-colon operator.  It always seemed to me one
# of the constructs in C most open to abuse.
#
# What's that?  Oh, okay, so how would you eliminate that ?: in favor
# of something more Rubyish?

(1..100).each{|i|
  x = i
  x = 'Fizz' if i%3==0
  x += 'Buzz' if i%5==0 rescue x='Buzz'
  puts x;
}

# Well using "rescue" certainly does feel more Rubyish.
#
# It says here that you've done significant work with functional
# languages.  Could you rewrite this to take advantage of higher order
# functions?

a = [proc{|x|x}, proc{|x|x}, proc{:Fizz}] * 5
a[4]=a[9]=proc{:Buzz}
a[14]=proc{:FizzBuzz}
(1..100).zip(a*9){|i,l|puts l[i]}

# Well that's rather cryptic, and I don't necessarily like the manual
# computation behind the indexes 4, 9, and 14.  I'd prefer something
# that, like your first two solutions, combined the Fizz and Buzz so
# that the FIzzBuzz printed every fifteen spots is a natural
# consequence.

f = proc{'Fizz'}
b = proc{|x|x+'Buzz' rescue :Buzz}
i = proc{|x|x}
(1..100).zip([i,i,f]*99,[i,i,i,i,b]*99){|n,p,q|puts q[p[n]]}

# Uh... yes.  In that I can see the two cycles, the 3-cycle and the
# 5-cycle, but I'm not sure that turned out as clear as I had hoped.
#
# I wonder if a hybrid approach where you used anonymous functions
# only for one of the two words is worth considering...

b=proc{|i,s|i%5==0?s+'Buzz':s rescue :Buzz}
puts (1..100).map{|i|b[i,i%3==0?'Fizz':i]}

# There's that ?: operator again.
#
# You know, you aren't really using arbitrary functions there.  I wonder
# if lambda functions aren't overkill for this problem.  What if you
# repeated the pattern where you showed the two cycles, but used simple
# strings instead?

$;='/'
(1..100).zip('//Fizz'.split*99,'////Buzz'.split*99) {|a|
puts(('%d%s%s'%a).sub(/\d+(?=\D)/,''))}

# Well, okay, you've shown that sometimes strings are not as easy to read
# as one might think.
#
# I noticed you using a regular expression there and I note that your
# resume shows extensive experience with regular expressions.  That's a
# rather small example on which to judge your regular expression
# experience.  Could you somehow make more use of regular expressions?

(1..100).map{|i|"#{i}\n"}.join.
  gsub(/^([369]?[0369]|[147][258]|[258][147])$/m,'Fizz\1').
  gsub(/\d*[50]$/m,'Buzz').gsub(/z\d+/,'z').display

# Let us never speak of this again.
#
# Well, Mr. Martin, I think you've shown technically what we're looking
# for.  Tell me, do you golf?

puts (1..100).map{|a|x=a%3==0?'Fizz':'';x+='Buzz'if a%5==0;x.empty?? a:x}

# Uh, that

puts (1..100).map{|i|[i,:Buzz,:Fizz,:FizzBuzz][i%5==0?1:0+i%3==0?2:0]}

# Mr. Martin, that's not

puts (1..100).map{|i|i%15==0?:FizzBuzz:i%5==0?:Buzz:i%3==0?:Fizz:i}

# I, uh, hadn't meant that kind of golf.
# (Though, as an aside, you could save characters by using 1.upto(100)
#  and by using <1 in place of ==0)
#
# However, these last few examples bring home a point I was worrying about
# before that we haven't really touched on yet - all of these have 
# varying degrees of readability, yet Ruby is supposed to be an eminently
# readable language.  How could you make this code more readable?

puts (1..100).map{|i|
  case i%15
  when 0        then :FizzBuzz
  when 5,10     then :Buzz
  when 3,6,9,12 then :Fizz
  else i
  end
}

# Well, that certainly is an improvement, though separating the "puts"
# from the rest of the logic might be slightly confusing and I'd prefer
# a more direct translation from the English program specification to
# the code.

(1..100).each {|i|
  if    i%5==0 and i%3==0 then puts :FizzBuzz
  elsif i%5==0            then puts :Buzz
  elsif            i%3==0 then puts :Fizz
  else                         puts i
  end
}

# Well now.
#
# Okay, are there any other tricks you have to show before we wrap this
# up?

h=Hash.new{|d,k|k>14?h[k%15]:nil}
h[0]=:FizzBuzz
h[3]=h[6]=h[9]=h[12]=:Fizz
h[5]=h[10]=:Buzz
puts (1..100).map{|i|h[i]||i}

# That looks rather familiar and similar to your first anonymous function
# solution.  I think we've both had enough of this problem by now.
#
# Well, it's been nice talking to you, Mr. Martin, and I thank you for
# your interest in CompuGlobalMegaTech.  We'll be in touch over the next
# few days with our decision.
