$DEBUG = false
 
# Dice Roller entry point
def roll_dice( dice_command, roll_count )
  begin
    puts "Executing #{roll_count} roll(s) of #{dice_command}"
    results, total = Dice.new( dice_command ).roll( roll_count )
    puts "Result: [#{results.join(', ')}] => #{total}"  
  rescue Exception => e
    puts "Roll error: #{e}"
  end
end
 
class Dice  
  # operator => [precendence, associativity]
  @@operators = { "d" => [3, :right],
                  "*" => [2, :left] , "/" => [2, :left],
                  "+" => [1, :left] , "-" => [1, :left]
                }
 
  # Initialize the Stacks and load the dice instructions
  def initialize( dice_command )    
    if $DEBUG
      alias :d :dnd_roll_loaded
    else
      alias :d :dnd_roll_random
    end
  
    @operator_stack, @value_stack = [], []
    prepare_instructions( dice_command )
  end
 
  def roll( roll_count )
    results = (1..roll_count).collect { execute }
    [results, results.inject {|sum, item| sum + item } || 0]
  end  
  
  private
  
  # The infix command is parsed into tokens and then executed using
  # The Shunting Yard Algorithm. Evaluation is done "on-the-fly" as
  # items are placed on the value stack (acting as the post-fix "output").
  def execute
    @operator_stack.clear
    @value_stack.clear
 
    # Process the tokens in L -> R order
    # Look for non-digit characters and numbers
    @instructions.scan(/\D|\d+/) do | token |
      case token
        when "("
          @operator_stack.push token
 
        when /\d+/ # any number
          @value_stack.push token.to_i
          
        when /[-\+*\/d]/ # the operators
          finished = false
          until finished or @operator_stack.empty?
            if higher_operator(token)
              finished = true
            else
              resolve_expression
            end
          end
          @operator_stack.push token
 
        when ")"
          resolve_expression while @operator_stack.last != "("
          @operator_stack.pop
          
        else
          raise "Invalid token found: #{token}"
      end
    end
 
    resolve_expression while !@operator_stack.empty?
 
    raise "Unexpected problem. #{@value_stack.size} values remain after execution." \
      unless @value_stack.size == 1
    @value_stack.pop
  end    
 
  def resolve_expression
    opr, rhv, lhv = @operator_stack.pop, @value_stack.pop, @value_stack.pop
    raise "No more values left for #{opr} to consume!" unless rhv && lhv
    
    value = (opr == "d") ? value = d( lhv, rhv ) : lhv.send( opr, rhv )
    @value_stack.push value.to_i
  end
  
  def dnd_roll_random( roll_count, die_value )
    (1..roll_count).inject(0) { |value, item| value + ( rand(die_value) + 1 ) }
  end
 
  def dnd_roll_loaded( roll_count, die_value )
    roll_count * die_value
  end
  
  def higher_operator(opr)
    if associativity(opr) == :left
      precedence(opr) > precedence(@operator_stack.last)
    else
      precedence(opr) >= precedence(@operator_stack.last)    
    end
  end
  
  def precedence(opr)
    @@operators[opr] ? @@operators[opr][0] : 0
  end
 
  def associativity(opr)
    @@operators[opr] ? @@operators[opr][1] : :left
  end
 
  def prepare_instructions( dice_command )
    # 1) Eliminate all whitespace.
    # 2) Substitute d100 for d% 
    # 3) Insert the implied 1 if a d is the first character
    #    or is preceded by an operator other than ')'
    @instructions = dice_command.gsub(/\s+/, '')    
    @instructions.gsub!(/d%/, 'd100')
    @instructions.gsub!(/([-\+*\/(d]|\A)(?=d)/, '\11')   
    puts "Normalized instructions: #@instructions" if $DEBUG
    
    raise "Unmatched left / right parenthesis" unless \
      @instructions.scan(/\(/).size == @instructions.scan(/\)/).size
  end  
end
 
# Argument parsing
if $0 == __FILE__
  raise "DiceRoller dice_command [roll_count=1]" unless (1..2).include?(
ARGV.length )
  roll_dice(ARGV[0], ARGV[1] ? ARGV[1].to_i : 1)
end
