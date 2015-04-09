class Integer
  def fizz_buzz
    result = ''
    result += 'Fizz' if self % 3 == 0
    result += 'Buzz' if self % 5 == 0
    result = self if result.empty?
    result
  end
end

(1..100).each { |i| puts i.fizz_buzz } if __FILE__ == $0
