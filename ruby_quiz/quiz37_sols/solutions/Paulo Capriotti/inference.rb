require 'graph'

def opposite_type(type)
  type == :provable_true ? :provable_false : :provable_true
end

class Property
  attr_reader :name, :type
  def initialize(name, type)
    @name = name
    @type = type
  end
  
  def opposite
    Property.new(@name, @type == :positive ? :negative : :positive)
  end
  
  def Property.create(x)
    if x.respond_to?(:opposite)
      x
    else
      Property.new(x, :positive)
    end
  end
  
  def hash
    "#{@name}##{@type}".hash
  end
  
  def eql?(other)
    @name == other.name and @type == other.type
  end
  
  alias == eql?
  
  def to_s
    res = @name
    if @type == :negative
      "not-" + res
    else
      res
    end
  end
end


class Knowledge < DirectedHashGraph
  attr_reader :contradiction
  
  def initialize
    @contradiction = false
    super
  end
  
  # Add a property and some tautologies.
  # Here we assume that the property and
  # its opposite are not void.
  def add_property(x)
    x = Property.create(x)
    safe_add_edge(x, x.opposite, :provable_false)
    safe_add_edge(x.opposite, x, :provable_false)
    safe_add_edge(x, x, :provable_true)
    safe_add_edge(x.opposite, x.opposite, :provable_true)
    x
  end

  # Add en edge. Never throw.
  def safe_add_edge(x, y, type)
    catch(:add_edge_throw) do 
      add_edge(x, y, type)
    end
  end
  
  # Add an edge. Throw if the edge already exists.
  def add_edge(x, y, type)
    debug_msg "adding edge #{x}, #{y}, #{type}"
    if self[x,y]
      unless self[x,y] == type
        @contradiction = true
        debug_msg " \tcontradiction"
        throw :add_edge_throw, :contradiction
      else
        debug_msg "\ti know"
        throw :add_edge_throw, :i_know
      end
    else
      super(x, y, type)
    end
  end
  
  # Add an edge and its contrapositive.
  def add_assertion(*args)
    x, y, type = get_stmt(*args)
    catch(:add_edge_throw) do
      add_edge(x, y, type)
      add_edge(y.opposite, x.opposite, type)
      :normal
    end
  end
  
  # Extract statement values.
  def get_stmt(*args)
    case args.size
    when 1
      x, y, type = args[0].x, args[0].y, args[0].type
    when 3
      x, y, type = args[0], args[1], args[2]
    else
      raise "Invalid argument list in #{caller.first}"
    end  
    return add_property(x), add_property(y), type
  end
  
  # Discover all possible deductions
  # and add the corresponding edges to the graph.
  def deduce
    each_vertex do |v1|
      each_vertex do |v2|
        each_vertex do |v3|
        
          if self[v1,v2] == :provable_true and self[v2,v3] == :provable_true
            add_assertion(v1, v3, :provable_true)
          end
          
          if self[v2,v1] == :provable_false and self[v2,v3] == :provable_true
            add_assertion(v3, v1, :provable_false)
          end
          
          if self[v1,v2] == :provable_true and self[v3,v2] == :provable_false
            add_assertion(v3, v1, :provable_false)
          end
          
          break if @contradiction
        end
      end
    end
  end
  
  # Return true if a statement is provable.
  # Return false if its negation is provable.
  # Return nil if it is undecidable.
  def test(*args)
    x, y, type = get_stmt(*args)
    case self[x,y]
    when nil
      return nil
    when type
      return true
    else
      return false
    end
  end


end

["Assertion", "Question"].each do |c|
  Struct.new(c, :x, :y, :type)
end

class UI

  # Parse input and return a statement
  def get_statement(line)
    case line
    # assertions
    when /^all (.*)s are (.*)s\.?$/
      return Struct::Assertion.new(Property.create($1), Property.create($2), :provable_true)
    when /^no (.*)s are (.*)s\.?$/
      return Struct::Assertion.new(Property.create($1), Property.create($2).opposite, :provable_true)
    when /^some (.*)s are not (.*)s\.?$/
      return Struct::Assertion.new(Property.create($1), Property.create($2), :provable_false)      
    when /^some (.*)s are (.*)s\.?$/
      return Struct::Assertion.new(Property.create($1), Property.create($2).opposite, :provable_false)
    # questions
    when /^are all (.*)s (.*)s\?$/
      return Struct::Question.new(Property.create($1), Property.create($2), :provable_true)
    when /^are no (.*)s (.*)s\?$/
      return Struct::Question.new(Property.create($1), Property.create($2).opposite, :provable_true)
    when /^are any (.*)s not (.*)s\?$/
      return Struct::Question.new(Property.create($1), Property.create($2), :provable_false)      
    when /^are any (.*)s (.*)s\?$/
      return Struct::Question.new(Property.create($1), Property.create($2).opposite, :provable_false)
    # description
    when /^describe (.*)s\.?$/
      return Property.create($1)
    else 
      return nil
    end
  end

  # Return a description of the relation
  # between x and y. 
  # Assume that x is positive and that
  # x -> y is not undecidable.
  def describe_edge(x, y, aff = true)
    case @k[x,y]
    when :provable_true
      case y.type
      when :positive        
        return "All #{x.name}s are #{y.name}s"
      when :negative
        return "No #{x.name}s are #{y.name}s"
      end
    when :provable_false
      case y.type
      when :positive
        if aff
          return "Some #{x.name}s are not #{y.name}s"
        else
          return "Not all #{x.name}s are #{y.name}s"
        end
      when :negative
        if aff
          return "Some #{x.name}s are #{y.name}s"
        else
          return "Not all #{x.name}s are not #{y.name}s"
        end
      end
    end
  end
  
  # Return a list of sentences which describe
  # the relations between x and each other node.
  # Assume that x is positive.
  def describe_node(x)
    res = []
    @k.each_vertex do |y|
      if y.type == :positive and not x == y
        if @k[x,y] == :provable_true
          res << describe_edge(x,y)
        elsif @k[x,y.opposite] == :provable_true
          res << describe_edge(x,y.opposite)
        elsif @k[x,y]
          res << describe_edge(x,y)
        elsif @k[x,y.opposite]
          res << describe_edge(x,y.opposite)
        end
      end
    end
    
    res
  end  
  
  
  def say(value)
    case value
    when true
      "Yes"
    when false
      "No"
    else
      "I don't know"
    end
  end
  
  
  def initialize
    @k = Knowledge.new
  end

  def wait_for_input
    print '> '
    gets
  end
  
  def run
    while line = wait_for_input
      line.chomp!
      line.downcase!
      stmt = get_statement(line)
      if stmt.class == Struct::Assertion
        case @k.test(stmt)
        when true
          puts "I know"
        when false
          puts "Sorry, that contradicts what I already know"
        else
          @k.add_assertion(stmt)
          @k.deduce
          puts "OK"
        end
      elsif stmt.class == Struct::Question
        value = @k.test(stmt)
        print say(value)
        if value.nil?
          print "\n"
        else
          puts ", #{describe_edge(stmt.x, stmt.y, value).downcase}"
        end
      elsif stmt.class == Property
        describe_node(stmt).each do |sentence|
          puts sentence
        end
      else
        puts "I don't understand"
      end
    end
  end
end

def debug_msg(msg)
  puts msg if $debug
end

if $0 == __FILE__
  ui = UI.new
  ui.run
end
