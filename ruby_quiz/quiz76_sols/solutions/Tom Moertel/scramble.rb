# Ruby Quiz 76
# http://www.rubyquiz.com/quiz76.html
#
# Solution of Tom Moertel
# http://blog.moertel.com/
# 2006-04-21
#
# Usage:  munge.rb [inputs...]

class String
   def munge!
    (length - 2).downto(2) do |i|
      j = rand(i) + 1
      self[i], self[j] = self[j], self[i]
    end
    self
  end
end

while line = gets
  puts line.gsub(/\w+/) { |s| s.munge! }
end
