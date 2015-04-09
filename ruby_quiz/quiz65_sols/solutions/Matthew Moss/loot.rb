class Numeric
   def positive?
      self > 0
   end
end

class Array
   def tail
      self[1..-1]
   end

   def sum
      inject { |s, k| s + k }
   end

   def find_sum(n)
      if not empty? and n.positive?
         if n == first
            return [first]
         else
            sub = tail.find_sum(n - first)
            return [first] + sub unless sub.nil?
            return tail.find_sum(n)
         end
      end
      nil
   end
end

guys = ARGV.shift.to_i
loot = ARGV.map { |i| i.to_i }.sort

total = loot.sum

unless (total % guys).zero?
   puts "It is not possible to fairly split this treasure #{guys} ways."
else
   share = total / guys

   shares = []
   guys.times do |i|
      mine = loot.find_sum(share)
      unless mine.nil?
         mine.each { |k| loot.delete_at(loot.index(k)) }
         shares << mine
      end
   end

   if shares.size == guys
      shares.each_with_index do |s, i|
         puts "#{i}: #{s.join(' ')}"
      end
   else
      puts "It is not possible to fairly split this treasure #{guys} ways."
   end
end
