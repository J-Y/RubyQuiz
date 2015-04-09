class Fixnum
  @@old_to_s = 1.method(:to_s).unbind
  def to_s
    s = ((self % 3 == 0 ? "Fizz" : "") + (self % 5 == 0 ? "Buzz" : ""))
    s.empty? ? @@old_to_s.bind(self).call : s
  end
end

(1..100).each { |x| p x }
