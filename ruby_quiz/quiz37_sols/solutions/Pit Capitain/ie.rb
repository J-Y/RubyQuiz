
module IE extend self

  RULES = {
    [ "tff" ] => "ttt",
    [ "ttf" ] => "tft",
    [ "tff", "tff" ] => "tff", [ "ftf", "ftf" ] => "ftf",
    [ "tff", "ttf" ] => "ttf", [ "ttf", "ftf" ] => "ttf",
    [ "ttt", "tff" ] => "ttt", [ "ftf", "ttt" ] => "ttt",
    [ "ttt", "ttf" ] => "tft", [ "ttf", "ttt" ] => "ftt",
  }

  @names, @sets = {}, {}

  def enter_all( name1, name2 )
    enter( name1, "t", name2, "f", "f" )
  end

  def enter_no( name1, name2 )
    enter( name1, "t", name2, "t", "f" )
  end

  def enter_some( name1, name2 )
    enter( name1, "t", name2, "t", "t" )
  end

  def enter_some_not( name1, name2 )
    enter( name1, "t", name2, "f", "t" )
  end

  def enter( name1, pos1, name2, pos2, val )
    case set( name1, pos1, name2, pos2, val )
    when true
      "OK."
    when false
      "Sorry, that contradicts what I already know."
    when nil
      "I know."
    end
  end

  def query_all( name1, name2 )
    query( name1, "t", name2, "f", "No, not all", "", "Yes, all" )
  end

  def query_no( name1, name2 )
    query( name1, "t", name2, "t", "No, some", "", "Yes, no" )
  end

  def query_any( name1, name2 )
    query( name1, "t", name2, "t", "Yes, some", "", "No, no" )
  end

  def query_any_not( name1, name2 )
    query( name1, "t", name2, "f", "Yes, some", " no", "No, all" )
  end

  def query( name1, pos1, name2, pos2, true_msg, no_msg, false_msg )
    case get( name1, pos1, name2, pos2 )
    when "t"
      "#{true_msg} #{name1} are#{no_msg} #{name2}."
    when "f"
      "#{false_msg} #{name1} are #{name2}."
    when nil
      "I don't know."
    end
  end

  def describe( name1 )
    result = []
    if known?( name1 )
      each_without( name1 ) do |name2|
        val1 = get( name1, "t", name2, "f" )
        val2 = get( name1, "t", name2, "t" )
        if val1 == "f"
          result << description( "All", name1, "", name2 )
        elsif val2 == "f"
          result << description( "No", name1, "", name2 )
        else
          if val1 == "t"
            result << description( "Some", name1, " no", name2 )
          end
          if val2 == "t"
            result << description( "Some", name1, "", name2 )
          end
        end
      end
    else
      result << unknown( name1 )
    end
    result.sort
  end

  def description( prefix1, name1, prefix2, name2 )
    "#{prefix1} #{name1} are#{prefix2} #{name2}."
  end
  
  def split( words )
    words1, words2 = [], words
    until words2.empty?
      words1 << words2.shift
      name1, name2 = words1.join( " " ), words2.join( " " )
      valid1, valid2 = known?( name1 ), known?( name2 )
      break if valid1 or valid2
    end
    invalid = if !valid1 then name1 elsif !valid2 then name2 end
    [ name1, name2, unknown( invalid ) ]
  end

  def add( *names )
    names.each do |name|
      unless known?( name )
        @names[ name ] = true
        set( name, "t", name, "f", "f" )
      end
    end
  end

  def known?( name )
    @names.has_key?( name )
  end

  def unknown( name )
    "I don't know anything about #{name}." if name
  end

  def set( name1, pos1, name2, pos2, val )
    if pos1 or pos2
      old = get( name1, pos1, name2, pos2 )
      if old.nil?
        add( name1, name2 )
        put( name1, pos1, name2, pos2, val )
        changed( name1, pos1, name2, pos2, val )
        true
      elsif old != val
        false
      end
    end
  end

  def put( name1, pos1, name2, pos2, val )
    key = key( name1, pos1, name2, pos2 )
    @sets[ key ] = val
  end

  def get( name1, pos1, name2, pos2 )
    key = key( name1, pos1, name2, pos2 )
    @sets[ key ]
  end

  def key( name1, pos1, name2, pos2 )
    name1, pos1, name2, pos2 = name2, pos2, name1, pos1 if name2 < name1
    "#{name1}, #{pos1}, #{name2}, #{pos2}"
  end

  def changed( name1, pos1, name2, pos2, val )
    RULES.each do |rule, action|
      check( name1, pos1, name2, pos2, val, rule, action )
      check( name2, pos2, name1, pos1, val, rule, action )
    end
  end

  def check( name1, pos1, name2, pos2, val, rule, action )
    if "#{pos1}#{pos2}#{val}" == rule[ 0 ]
      if rule.size == 1
        perform( name1, name2, action )
      else
        each_without( name1, name2 ) do |name3|
          perform( name1, name3, action ) if match( name2, name3, rule[ 1 ] )
        end
      end
    end
  end

  def each_without( name1, name2 = nil )
    @names.keys.each do |name|
      yield name if name != name1 && name != name2
    end
  end

  def match( name1, name2, rule )
    pos1, pos2, val = rule.split( // )
    val == get( name1, pos1, name2, pos2 )
  end

  def perform( name1, name2, action )
    pos1, pos2, val = action.split( // )
    set( name1, pos1, name2, pos2, val )
  end

  
  def use_irb

    $VERBOSE = nil

    Object.send( :define_method, :method_missing ) do |name, *args|
      name = name.to_s.downcase
      line = if args.empty? then name else "#{name} #{args}" end
      case line
      when /^some (.*) are no (.*)/
        IE.enter_some_not( $1, $2 )
      when /^(all|no|some) (.*) are (.*)/
        IE.send( "enter_#{$1}", $2, $3 )
      when /^are any (.*) no (.*)\?/
        IE.query_any_not( $1, $2 )
      when /^are (all|no|any) (.*)\?/
        method, words = "query_#{$1}", $2.split
        name1, name2, error = IE.split( words )
        error || IE.send( method, name1, name2 )
      when /^describe (.*)/
        IE.describe( $1 ).join( "\n   " )
      else
        line
      end
    end

    String.send( :alias_method, :inspect, :to_s )

  end

  use_irb unless caller.grep( /\/irb\// ).empty?

end

