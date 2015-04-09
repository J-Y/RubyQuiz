class PostfixToInfix
  OPERATORS = %w{* / + -}
  
  def initialize(postfix)
    raise "Requires a postfix expression as a string." unless postfix.class == String
    raise "Requires a valid postfix expression." unless postfix.split.length >= 3
    @postfix = postfix
  end
  
  def convert(verbose=true)
    postfix_terms = @postfix.split
    
    if verbose
      convert_verbose(postfix_terms)
    else
      raise NotImplementedError("Because I'm pressed for time.")
    end
  end
  
  def convert_verbose(postfix_terms)
    infix_terms = []
    
    while not postfix_terms.empty?
      current_term = postfix_terms.shift
      
      if OPERATORS.include? current_term
        # Perform the old switcheroo.
        right = infix_terms.pop
        left = infix_terms.pop
        current_term = "(#{left} #{current_term} #{right})"
      end
      
      infix_terms.push current_term
    end
    
    return infix_terms.shift
  end
end

if __FILE__ == $0
  unless ARGV.length == 1
    puts "Usage: #{$PROGRAM_NAME} <postfix_string>"
    exit
  end
  
  ps2i = PostfixToInfix.new(ARGV.shift)
  puts ps2i.convert
end