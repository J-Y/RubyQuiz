class Fixnum
  def to_s
    str = ''
    str += 'Fizz' if (self % 3).zero?
    str += 'Buzz' if (self % 5).zero?
    str = '%d' % self if str.empty?
    str
  end
end

(1..100).each { |x|  puts x }
