# Peter Seebach "extra fun" solution

class Fixnum
  alias old_to_s to_s

  def to_s
    value = ""
    value += "Fizz" if 0 == self % 3
    value += "Buzz" if 0 == self % 5
    value += self.old_to_s if "" == value
    value
  end
end

(0..100).each { |x| p x }

# make things right again
class Fixnum
  alias to_fizz_buzz to_s
  alias to_s old_to_s
end
