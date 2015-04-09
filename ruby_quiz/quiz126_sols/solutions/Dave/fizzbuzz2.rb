#Lets play with Fixnum

class Fixnum
  def fizz_buzzed
    a= (self%3==0 ? 'Fizz' : "")
    a+= 'Buzz' if self%5==0
    a= self.to_s if a==""
    a
  end
end

1.upto(100) {|i| puts i.fizz_buzzed}
