  class EmotiveNumber
  CYCLIC_NUMBERS = [4, 16, 37, 58, 89, 145, 42, 20]
  attr_reader :suite
  
  def initialize(seed)
    @suite = []
    compute_suite(seed)
  end
  
  def happy?
    suite.last == 1
  end
  
  def size
    suite.size
  end

private
  
  def compute_suite(seed)
    next_element = seed
    while (!happy? && !CYCLIC_NUMBERS.include?(next_element))
      @suite << next_element
      next_element = square_sum(@suite.last)
    end
    @suite += CYCLIC_NUMBERS if !happy?
  end
  
  def square_sum(num)
    num.to_s.split(//).inject(0){|result, i| result += i.to_i*i.to_i}
  end
end
