class Fixnum
 def factorial
   (1..self).to_a.inject(1) { |sum,i| sum *= i }
 end

 def choose(k)
   self.factorial / (k.factorial * (self - k).factorial)
 end

 def times_for_collection
   collection = []
   times { |i| collection << yield(i) }
   collection
 end
end

class Array
 def to_triangle
   collect { |row| ' ' * ((last.size - row.size) / 2) + row + "\n" }.join
 end
end

ARGV[0].to_i.times_for_collection do |n|
 (n + 1).times_for_collection do |k|
   (k == 0 ? '%d' : '%6d') % (n > 1 ? (n - 1).choose(k - 1) + (n - 1).choose(k) : 1)
 end.join
end.to_triangle.display
