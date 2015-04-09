#Ruby quiz #148
require 'pp'

class Quiz148
  
  def initialize(str)
    @regexed_string = str.scan(/\d+\.\d*|[-*+\/]|\d*/)
    @regexed_string.reject! {|i| i == "" }
    @num_stack = []
    
    postfix_to_infix
  end 
  
  def postfix_to_infix
    @regexed_string.each do |c|
    case c
      when "*"
        if check_validity
          one,two = eval_parens(@num_stack.pop), @num_stack.pop
          @num_stack.push(two + c +one) 
        end
      when "/"
        if check_validity
          one,two = eval_parens(@num_stack.pop), eval_parens(@num_stack.pop)
          @num_stack.push(two + c +one)
        end
      when "+", "-" 
        if check_validity
          one,two = @num_stack.pop, @num_stack.pop
          @num_stack.push(two + c + one)
        end
      else  # - we've got a number!
        @num_stack.push(c)
      end  # - case c  
    end  # - @regexed_string.each do |c|
  end
  
  def eval_parens(str)
    if (str.include? "*") || (str.include? "+") || (str.include? "-") || (str.include? "/")
      "(" + str + ")"
    else
      str
    end
  end
  
  def check_validity
    if @num_stack.size == 1
      puts "Oh no, looks like your expression has too many operators?!  Breaking early!" 
      return false
    end
    return true
  end
  
  def to_s
    if @num_stack.size > 1
      puts "Looks like your expression has too many operands :( Gonna just print what we've got" 
    end
    @num_stack.first.to_s
  end
end
#A few tests!
if ARGV[0]
  puts Quiz148.new(ARGV[0]).to_s
end
puts Quiz148.new("56 34 213.7 + * 678 - +").to_s
puts Quiz148.new("3 5 * 5 8 * /").to_s 
puts Quiz148.new("3 5 * 5 ").to_s