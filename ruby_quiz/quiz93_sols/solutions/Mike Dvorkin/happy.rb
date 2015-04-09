class Integer
    @@found = {}
    def happy?
      sum = 0
      self.to_s.scan(/./u) { |c| sum += c.to_i ** 2 }
      sum == 1 || @@found[sum] ? 1 : (@@found[sum] = 1; sum.happy?)
  end
end

puts 1234567890.happy? # => 1
