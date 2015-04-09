#!/usr/bin/env ruby

=begin
A frequency table, stored as an array of (value,probability) pairs
Can be constructed empty, as a fixed integer value with a probability
of one, or as a uniform distribution from 1 to n
=end
class Freq_dist

  class Freq
    attr_accessor :value, :p
    def initialize( v, p )
      @value = v
      @p = p
    end
    def <=> ( other )
      @value <=> other.value
    end
    def to_s
      print "[#{value},#{p}] "
    end
  end

  attr_reader :prob

  def initialize()
    @prob = []
    self
  end

  def uniform(n)
    n.times { |i| @prob.push( Freq.new( i+1, 1.0/n ) ) }
    self
  end

  def integer(n)
    @prob = [Freq.new(n,1.0)]
    self
  end

  def set_arr( dist )
    @prob = dist
    self
  end

  def to_s
    string=""
    check_total = 0.0
    @prob.each do |el|
      string += ( "#{el.value}\t#{el.p}\n" )
      check_total += el.p
    end
    string += ( "Check total: #{check_total}\n" )
    string += stats
  end

  def coalesce
    sorted_prob=@prob.sort
    @prob = []
    sorted_prob.each do |i|
      if @prob.empty? or ( i.value != @prob.last.value )
	@prob.push(i)
      else
	@prob.last.p = @prob.last.p + i.p
      end
    end
  end      

=begin
These two methods are for building up distributions: merging
produces a part-distribution where the probability assigned to
each value is the sum of the probabilities assigned to that value
in the two part-distributions self and other
=end
  def merge ( other )
    new_dist = Freq_dist.new.set_arr(@prob + (other.prob))
    new_dist.coalesce
    new_dist
  end

  def scale_prob( factor )
    new_dist = Freq_dist.new.set_arr( @prob.map { |x| Freq.new( x.value, x.p * factor ) } )
  end

=begin
  These produce the distribution of a random variable which
  is a function of two other random variables with distributions
  provided (self and other
=end
  def combine( other )
    if other.kind_of?(Numeric)
      return combine_int( other ) { |x,y| yield(x,y) }
    end

    new_dist = []
    @prob.each do |el1| 
      other.prob.each do |el2|
	new_dist.push( Freq.new( yield( el1.value, el2.value ),
				el1.p * el2.p))
      end
    end
    result = Freq_dist.new
    result.set_arr( new_dist.sort )
    result.coalesce
    result
  end

  def combine_int( x )
    result = Freq_dist.new
    new_dist = []
    @prob.each do |el|
      new_dist.push( Freq.new( yield( el.value, x ), el.p ) )
    end
    result.set_arr( new_dist )
  end

  def + (a) ; combine( a ) { |x,y| x+y } end
  def - (a) ; combine( a ) { |x,y| x-y } end
  def * (a) ; combine( a ) { |x,y| x*y } end
  def / (a) ; combine( a ) { |x,y| x/y } end

  def mean
    @prob.inject(0.0) { |tot,el| tot + el.value * el.p }
  end

  def sig_x2
    @prob.inject(0.0) { |tot,el| tot + el.value * el.value * el.p }
  end

  def var
    mu = mean
    sig_x2 - mu * mu
  end

  def std_dev
    Math.sqrt( var )
  end

  def stats
    "Mean #{mean}  std. dev #{std_dev}"
  end
end

=begin
This evaluates an already-parsed expression, generating an
appropriate random number for each dice roll
=end
class Evaluator
  def initialize( parent )
    @parsed_expr = parent
  end

  def null_value
    return 0
  end

  def subtree(side)
    self.class.new(@parsed_expr.subtree(side))
  end

  def eval_binop( force_same_type = true )
    subtree(:left).evaluate do |l| 
      subtree(:right).evaluate do |r| 
	yield(l,r)
      end
    end
  end

  def roll_one( sides )
    val = 1 + rand(sides)
#    puts( "Rolled D#{sides} got #{val}" )
    yield val
  end    

  def roll_dice( numdice, sides )
    if ( numdice == 0 )
      yield null_value
    else
      roll_one(sides) do |first|
	roll_dice( numdice-1, sides ) do |rest|
	  yield( first + rest )
	end
      end
    end
  end

  def evaluate
    case (@parsed_expr[0] )
    when :integer
      yield @parsed_expr[1]
    when :expr
      case (@parsed_expr[1][1])
      when :mult
	eval_binop { |x,y| yield x*y }
      when :plus
	eval_binop { |x,y| yield x+y }
      when :minus
	eval_binop { |x,y| yield x-y }
      when :divide
	eval_binop { |x,y| yield x/y }
      when :dice
	eval_binop(false) do |numdice,sides|
	  roll_dice( numdice, sides ) { |x| yield x }
	end
      else
	throw "Evaluation error"
      end
    else
      throw "Evaluation error"
    end
  end
end


# This is used by the ParseTree to generate its own state 

class Parser
  def initialize( debug = false )
    @stack = [[:start]]
    @state = :start
    @debug = debug
  end

  @@precedence = { :dice => 4, :plus => 2, :minus =>2, :mult => 3, :divide =>3 }

  def tokenise( input )
    pos = 0
    len = input.length
    while ( pos < len ) do
      ch = input[pos..pos]
      if "()+-dD*/%".include? ch
	yield ch
      elsif " \n\t".include? ch
	;
      elsif ch =~ /[0-9]/
	numpos = pos
	while ( ( pos+1 < len ) && ( input[pos+1..pos+1] =~ /[0-9]/ ))
	  pos += 1
	end
	yield input[numpos..pos]
      else
	throw "invalid char #{ch}"
      end
      pos += 1
    end
    yield "END"
  end

  def parse( str )
    tokenise( str ) do |t|
      parse_t( t )
    end
    tree = pop
    if top[0] != :start
      throw "Syntax error: #{tree.inspect}, #{@stack.inspect}"
    else
      return tree
    end
  end

  def parse_t(tok)
    if @debug
      puts "Debug: stack = #{@stack.inspect}"
      puts "Debug: tok=#{tok} state=#{@state}"
    end
    method(@state).call(tok)
  end

  def push(x) ; @stack.push x ; end
  def pop ; @stack.pop ; end
  def top ; @stack.last ; end

  def collapse_top
    expr = pop
    if (( expr[0] == :expr ) || (expr[0] == :integer ))
      while true do
	if @debug
	  puts( "Debug: collapsing #{expr.inspect} on #{@stack.inspect}" )
	end
	if ( top[0] == :open )
	  push expr
	  break;
	elsif ( top[0] == :start )
	  push expr
	  break;
	elsif ( top[0] == :binop )
	  op = pop
	  left = pop
	  expr = [:expr, op, left, expr]
	elsif ( top[0] == :unop )
	  op = pop
	  expr = [:expr, op, expr ]
	else
	  throw "Syntax error #{expr.inspect}, #{@stack.inspect}"
	end
      end
    else
      throw "syntax error #{expr.inspect}, #{@stack.inspect}"
    end
  end

  def operator( op )
    prevop = @stack[-2]
    if ( prevop[0] == :binop ) || ( prevop[0] == :unop )
      if @@precedence[ op ] <= @@precedence[ prevop[1] ]
	collapse_top
      end
    end
    push [:binop, op]
    @state = :start
  end

  def start(tok)
    case tok
    when "("
      push [:open]
    when /[0-9]/
      t = top
      push [:integer, tok.to_i]	
      @state = :expr
    when /[dD]/
      push [:integer, 1]
      push [:binop, :dice]
    when "%"
      if top[1] == :dice
	push [:integer, 100]
	@state = :expr
      else
	throw "Syntax error at #{tok}"
      end
    else
      throw "Syntax error at #{tok}"
    end
  end

  def expr( tok )
    case tok
    when "END"
      collapse_top
    when /[dD]/
      operator( :dice )
    when "+"
      operator( :plus )
    when "*"
      operator( :mult )
    when "-"
      operator( :minus )
    when "/"
      operator( :divide )
    when ")"
      collapse_top
      expr = pop
      open = pop
      if open[0] != :open
	throw "Syntax error : #{open.inspect}, #{expr.inspect}, #{@stack.inspect}"
      end
      push expr
    when "("
      push [:open]
      @state = :start
    else
      push "ERROR"
    end
  end
end

=begin
This is the main interface to the whole thing: it parses an
expression and can evaluate it in different ways
=end
class ParseTree
  def initialize( source, debug = false )
    @debug = debug
    if source.kind_of?( String )
      parse( source )
    else
      @tree = source.to_a
    end
  end

  def to_a
    @tree
  end

  def [](x)
    @tree[x]
  end

  def parse( input )
    session = Parser.new( @debug )
    @tree = session.parse( input )
  end

  Operator_s = { :plus => "+", :minus => "-", :mult => "*", 
    :divide => "/", :dice => "D" }

  def subtree( lr )
    if lr == :left
      return ParseTree.new( @tree[2], @debug )
    elsif lr == :right
      return ParseTree.new( @tree[3], @debug )
    end
  end

  def prettify
    case ( @tree[0] )
    when :integer
      return @tree[1].to_s
    when :expr
      return "(" +
	subtree(:left).prettify +
	Operator_s[@tree[1][1]] +
	subtree(:right).prettify +
	")"
    end
  end

  def evaluate_random
    Evaluator.new( self ).evaluate { |x| x }
  end

  def evaluate_dist
    Evaluator_dist.new( self ).evaluate { |x| x }
  end

  def evaluate_every
    Evaluator_every.new( self ).evaluate do |x| 
      yield x
    end
  end

  def evaluate_fudged( target )
    Evaluator_every.new( self ).evaluate do |x|
      if x.to_i == target
	return x
      end
    end
    return "Cannot get #{target}"
  end

end

# Subclass of Evaluator that yields every possible dice roll,
# with the probability of that specific roll 
class Evaluator_every < Evaluator

  class Roll_stat
    def initialize( roll, path="", prob=1.0 )
      @roll = roll
      @path = path
      @p = prob
    end
    def binop(other)
      if ( other.kind_of?( Numeric ) )
	other = Roll_stat.new(other)
      end
      Roll_stat.new( yield( @roll, other.roll ),
		    @path + other.path,
		    @p * other.p )
    end

    def + (other) ; binop(other) { |x,y| x+y } ; end
    def * (other) ; binop(other) { |x,y| x*y } ; end
    def - (other) ; binop(other) { |x,y| x-y } ; end
    def / (other) ; binop(other) { |x,y| x/y } ; end

    def concat( other )
      binop(other) { |x,y| y }
    end

    def Roll_stat.make( n )
      if ( n.kind_of?(Roll_stat) )
	n
      else
	Roll_stat.new( n )
      end
    end

    def to_s ; "#{roll}\t: #{path} p=#{p}" ; end
    def to_i ; @roll ; end
    attr_reader :roll, :path, :p
  end

  def roll_one( sides )
    if sides.kind_of?(Numeric) ; sides = Roll_stat.new(sides) ; end
    sides.to_i.times do |n|
      yield sides.concat(Roll_stat.new( n+1, "D#{sides.to_i}=#{n+1} ", 1.0/(sides.to_i) ))
    end
  end

  def null_value
    Roll_stat.new(0)
  end

  def roll_dice( numdice, sides )
    numdice = Roll_stat.make( numdice )
    sides = Roll_stat.make( sides )
    super( numdice.to_i, sides.to_i ) do |rolls|
      yield( numdice.concat(sides).concat(rolls) )
    end
  end

  def eval_binop( force_same_type = true )
    subtree(:left).evaluate do |l| 
      subtree(:right).evaluate do |r| 
	if force_same_type
	  if r.kind_of?( Roll_stat ) and ! l.kind_of?( Roll_stat )
	    l = Roll_stat.new(l)
	  end
	end
	yield(l,r)
      end
    end
  end
end

#Subclass of evaluator that returns
#a probability distribution for each dice roll
class Evaluator_dist < Evaluator
  def null_value
    return Freq_dist.new.integer(0)
  end

  def roll_one_fixed( sides )
    if ( sides >= 1 )
      return Freq_dist.new.uniform(sides)
    else
      throw  "Error - tried to roll #{sides}-sided die"
    end
  end

  def roll_one( sides )
    if sides.kind_of?( Numeric )
      yield roll_one_fixed( sides )
    else
      result = Freq_dist.new
      sides.prob.each do |pr|
	result = result.merge( roll_one_fixed( pr.value ).scale_prob( pr.p ) )
      end
      yield result
    end
  end

  def roll_dice( numdice, sides )
    if numdice.kind_of?( Numeric )
      yield( super( numdice, sides ) { |x| x } )
    else
      result = Freq_dist.new
      numdice.prob.each do |pr|
	rolls = pr.value
	if rolls < 0
	  throw "Negative number of dice #{rolls}"
	end
	score = Freq_dist.new.integer(0)
	pr.value.times do 
	  score = score + ( roll_one( sides ) { |x| x } )
	end
	result = result.merge( score.scale_prob( pr.p ) )
      end
      yield result
    end
  end

  def eval_binop( force_same_type = true )
    subtree(:left).evaluate do |l| 
      subtree(:right).evaluate do |r| 
	if force_same_type
	  if r.kind_of?( Freq_dist ) and ! l.kind_of?( Freq_dist )
	    l = Freq_dist.new.integer(l)
	  end
	end
	yield(l,r)
      end
    end
  end
end

# Extra test method
class ParseTree
  def ParseTree.testp( input )
    puts "\nParser test: #{input}\n\n"
    t = ParseTree.new( input )
    puts "Roll spec is #{t.prettify}\n\n"
    puts "Parse tree is #{t.inspect}\n\n"
    puts "Random roll: #{t.evaluate_random}\n\n"
    puts "Distribution:\n#{t.evaluate_dist.to_s}\n\n"
    puts "All possible rolls:"
    t.evaluate_every do |outcome|
      puts outcome.to_s
    end
    puts "\n\n"
  end
end

case ARGV[0]
when "-full"
  ParseTree.testp( ARGV[1] )
when "-test"
  ["d6", "3d4", "4*(d3)", "7+4*2d6", "dd8", "(d4)d4", "d10-d10"].each do |str|
    ParseTree.testp( str )
  end
when "-dist"
  d = ParseTree.new(ARGV[1])
  puts "Distribution:\n#{d.evaluate_dist.to_s}\n\n"
when "-cheat"
  d = ParseTree.new(ARGV[1])
  target = ARGV[2].to_i
  puts d.evaluate_fudged( target )  
when "-help"
  puts "#{$0} expr [count]\n\tRoll dice as per expr (count times)"
  puts "#{$0} -test\n\tRun some predefined expressions"
  puts "#{$0} -dist expr\n\tProduce a probability distribution for an expression"
  puts "#{$0} -cheat expr value\n\tFind dice rolls in expression that produce value"
  puts "#{$0} -full expr\n\tDo everything with an expression, including listing every possible\n\tcombination of dice rolls (potentially very large output,\n\ttaking a very long time"
else
  d = ParseTree.new(ARGV[0])
  (ARGV[1] || 1).to_i.times { print "#{d.evaluate_random}  " }
  puts ""
end
