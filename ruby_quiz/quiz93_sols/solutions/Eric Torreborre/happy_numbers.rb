require "emotive_number"

class Fixnum
  def happy_number?
    EmotiveNumber.new(self).happy?
  end
end

def find_happy_numbers(n)
  (1..n).select{|seed| seed.happy_number?}
end

def find_happiest_number(n)
  happiest, max_size = 1, 1 
  (1..n).each do |seed|
    emotive = EmotiveNumber.new(seed)
    happiest, max_size = seed, emotive.size if (emotive.happy? && emotive.size > max_size) 
  end
  return happiest
end
