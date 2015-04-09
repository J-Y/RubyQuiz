class Integer
  def isHappy?
    return to_s.split(//).collect{|digit| digit.to_i**2}.inject{|sum, n| sum + n }.isHappy? while self!=1
    true
    rescue
    false
  end
end

puts 115485454654987986246476765451256546545241654555555555555555555555555555555555554125665146454122345444487.isHappy?
