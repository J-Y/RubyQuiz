class Integer
  def happy?
     return false if zero?
     return false if self == 4
     return true if self == 1
     to_s.split(//).inject(0) { |s,x| s + (x.to_i ** 2) }.happy?
  end
end
