#!/usr/bin/env ruby
# I am a newbie and thought this one seemed easy enough
# to jump in (especially since I "borrowed" the hard part
# from a previous Ruby Quiz). I would appreciate any
# comments improving my idiomatic ruby.
# - Mark Thomas ['ruby','thomaszone.com'].join('@')

# seed sentence
sentence = "LOOK AND SAY"

# iteration at which to give up (prevent runaway prog)
MAX = 10000

# I took this Monkey patched Integer class from
# Glenn Parker's Ruby Quiz #25 solution, which
# provides Integer#to_english

class Integer
  Ones = %w[ zero one two three four five six seven eight nine ]
  Teen = %w[ ten eleven twelve thirteen fourteen fifteen
             sixteen seventeen eighteen nineteen ]
  Tens = %w[ zero ten twenty thirty forty fifty
             sixty seventy eighty ninety ]
  Mega = %w[ none thousand million billion ]

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


def look_and_say(sentence)
  letters = {}
  letters.default = 0

  #put letters in a hash
  s = sentence.gsub(/[^A-Z]/,'')
  s.split('').each do |letter|
    letters[letter] = letters[letter] + 1
  end

  #say in english
  new_sentence = "";
  letters.sort.each do |letter,count|
    new_sentence << " " + count.to_english.upcase +
                    " " + letter
  end
  return new_sentence
end

#=================================================
# Main

puts "0. " + sentence

sentences = []

for i in 1..MAX
  break if sentences.index(sentence)
  print i.to_s + "."
  sentences << sentence
  new_sentence = look_and_say(sentence)
  puts new_sentence
  sentence = new_sentence
end

# Print Results

dupe  = i-1
first = sentences.index(sentence)
cycle = dupe - first

puts "Repeated at #{dupe} which was the same as #{first},"
puts "a cycle of #{cycle}"
