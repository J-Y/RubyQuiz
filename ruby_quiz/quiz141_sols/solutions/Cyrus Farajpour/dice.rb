#My first ruby quiz! http://www.rubyquiz.com/quiz141.html
#Cyrus Farajpour 

require 'pp'
class Integer #taken from http://readlist.com/lists/ruby-lang.org/ruby-talk/13/66945.html, by James Edward Gray II
  def fact
    (2..self).inject(1) { |f, n| f * n }
  end
end

class Array
  def count_fives
    count = 0
    self.each {|element| count += 1 if element == 5}
    count
  end
end

def cnr_loop(dice, count) #combinatorial action sauce
  answer = 1
  (count..(dice-1)).to_a.reverse.each_with_index do |a,index|
    index += 1
    answer += dice.fact / (a.fact * index.fact) * 5**index
  end
  answer
end

def array_for_roll(dice,roll) #kinda like counting in reverse order base 6
  roll -= 1
  array = Array.new(dice) {|i| 0}
  (0..(dice-1)).to_a.reverse.each do |position|
    if position == 0
      array[position] = roll
    else
      array[position] = roll/(6**position)# + 1
      roll -= roll/(6**position) * 6**position
    end
  end
  array.collect {|e| e += 1}
end

ARGV.reverse!
fives = ARGV[0].to_i
dice = ARGV[1].to_i

if ARGV.include?('-v') #dirty, especially since I use the print twice
  (1..(6**dice)).to_a.each do |num|
    array = array_for_roll(dice,num)
    puts "#{num.to_s.rjust(10)}  [#{array.join(',')}]  #{'<==' if array.count_fives >= fives}"
  end
end

if ARGV.include?('-s')
  count = 1
  while count < 6**dice
    array = array_for_roll(dice,count)
    puts "#{count.to_s.rjust(10)}  [#{array.join(',')}]  #{'<==' if array.count_fives >= fives}"
    count += 50000
  end
end

puts "\nNumber of desirable outcomes is #{cnr_loop(dice,fives)}"
puts "Number of possible outcomes is #{6**dice}"

puts "\nProbability is #{cnr_loop(dice,fives).to_f/(6**dice).to_f}"
