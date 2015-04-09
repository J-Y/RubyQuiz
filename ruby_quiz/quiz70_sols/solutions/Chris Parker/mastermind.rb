require 'CSP'
require 'generator'

class CodeMaker
  attr_reader :code
  def initialize(num_colors, num_spots)
    color_selector = (1 .. num_colors).to_a #produces an array of num_colors length from 1 to num_colors
    @code = []
    num_spots.times{|i|@code << color_selector[rand(num_colors)]}#rand returns a number >= 0 and < num_colors
  end
  
  def print_code
    print "The code is ",@code.inspect,".\n"
  end
  
  def test(possible_answer)
    dup_code = @code.dup
    dup_poss_ans = possible_answer.dup
    results = []
    correct_pos = @code.each_with_index{|code_val, index| 
      if code_val == possible_answer[index]
        results << :BLACK
        dup_poss_ans[index] = nil
        dup_code[index] = nil
      end
    }
    dup_code.each{|code_val|
      dup_poss_ans.each_with_index{|guess_val, index|
        if code_val && guess_val && code_val == guess_val
          results << :WHITE
          dup_poss_ans.delete_at(index)
          break
        end
      }
    }
    return results
  end

end

class CodeBreaker

  def initialize(num_colors, num_spots)
    @num_colors, @num_spots = num_colors, num_spots
  end
  
  def solve(code_maker)
    csp = CSP.new
    #csp.debug = true
    c = CSPConstraint.new
    @num_spots.times{|i|csp.add_var((i+1).to_s, (1 .. @num_colors)); c.add_var((i+1).to_s)}
    c.set_func(lambda{|*answer|results = code_maker.test(answer); return (!results.include?(:WHITE) && results.length == @num_spots)})
    csp.add_constraint(c)
    return csp.run
  end

end

class MasterMind
  attr_reader :code_breaker, :code_maker
  
  def initialize(num_colors, num_spots)
    @code_breaker = CodeBreaker.new(num_colors, num_spots)
    @code_maker = CodeMaker.new(num_colors, num_spots)
  end
  
  def solve
    return @code_breaker.solve(@code_maker)
  end
  
end