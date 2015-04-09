###############################################################################
# Ruby Quiz 138, Josef 'Jupp' Schugt
###############################################################################

# String#count creates a hash where the keys are the letters 'a'
# through 'z' and the values are the frequencies of these letters.

class String
  def count
    a = Hash.new(0)
    self.each_byte{|i| a[i.chr] += 1 if ('a'..'z').member?(i.chr)}
    a
  end
end

# Hash#say "reads the hash aloud"

class Hash
  def say
    self.sort.map{|n,c| "#{c.say} #{n}"}.join(' ')
  end
end

# Fixnum#say "reads the number aloud"

class Fixnum

  # Lookup table for numbers from zero to nineteen
  @@to20 = [ 'zero', 'one', 'two', 'three', 'four', 'five', 'six',
             'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve',
             'thirteen', 'fourteen', 'fivteen', 'sixteen',
             'seventeen', 'eighteen', 'nineteen' ]

  # Looup table for tens with the first two values only being fillers.
  @@tens = [ nil, nil, 'twenty', 'thirty', 'forty', 'fifty', 'sixty',
             'seventy', 'eighty', 'ninety' ]

  def say
    name = 
      case self
      when 0...20:
          @@to20[self]
      when 20...100:
          @@tens[self / 10 ] + '-' + @@to20[self % 10]
      when 100...1000:
          (self / 100).say + ' hundred ' + (self % 100).say
      when 1000...1_000_000:
          (self / 1000).say + ' thousand ' + (self % 1000).say
      when 1_000_000...1_000_000_000:
          (self / 1_000_000).say + ' million ' + (self % 1_000_000).say
      else
        raise ArgumentError, 'Only numbers from 0 to 999_999_999 are supported' end
    /[- ]zero$/.match(name) ? $~.pre_match : name
  end
end

puts <<EOF

PLEASE ENTER A STRING TO START WITH AND NOTE THAT:

  1. No output will be shown until processing is done.
  2. The string will be first downcased.
  3. All whitespace will be collapsed to single spaces.
  4. All characters except 'a' through 'z' and space are removed.

EOF

print "? "
s = gets.chomp.downcase.gsub(/\s+/, ' ').gsub(/[^a-z ]/, '')

arr = Array.new

until arr.member?(s)
  arr.push s
  s = s.count.say
end

puts <<EOF

VALUES BEFORE FIRST CYCLE

#{(0...arr.index(s)).map {|i| "#{i}:\t#{arr[i]}" }.join("\n")}

VALUES OF FIRST CYCLE

#{(arr.index(s)...arr.length).map {|i| "#{i}:\t#{arr[i]}" }.join("\n")}

SUMMARY

Initial value (step #{0}) is '#{arr.first}'

First cycle:

\tFirst step:\t#{arr.index(s)}
\tLast  step:\t#{arr.length - 1}
\tPeriod (steps):\t#{arr.length - arr.index(s)}

EOF
