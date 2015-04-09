#!/usr/bin/ruby

# possible solution to Ruby Quiz 78 on Bracket Parsing
# If string validates, it prints it and returns 0
# If string can be corrected, it prints the corrected version and returns 0 (should perhaps return 1 or otherwise signal correction?)
# If string cannot be corrected -- eg because there are two or more possible places for the correcting bracket to go --
# it returns 1 and prints a string indicating possible corrections

# works pretty much like a recursive descent parser, except that instead of looking only at
# the leftmost token, it uses regular expressions to find bracketed pairs.
# It parses from the outside in, or, if there are two or more pairs at the same level, from the left (or not, depending on ruby implementation)
# Parsing like this makes it easier to keep track of where we are to do corrections

# TODO? It might be nice if this corrected and/or signalled all errors at once instead of just one level at a time. That would require moving error
# marking/correction to within parsing, so that parsing always returns a complete value. Errors would then presumably be signalled
# via global @err_val

# QUESTION: is BB+ legal? It's not in this implementation, but should it be? It would be more ecological...

class BracketParser
  # called with string to parse
  def initialize( toparse )
    @spec = toparse
  end

  # qc initiates parsing and prints a viable spec string or error.
  # returns 0 if string usable, else 1
  def qc
    begin
      print "#{parse( @spec )}\n"
      return 0
    rescue UncorrectableError => uerr
      uerr.show
      return 1
    end
  end

  # parse does what it says, recursively
  def parse( spec )
#     print "parsing #{spec}\n"
    case spec
    when "B":           # contents of box, which is also a leaf of parse tree, so stop recursion
      return spec
    when /^(\[.+?\]|\(.+?\)|\{.+?\})((\[.+?\]|\(.+?\)|\{.+?\})+)$/    # two boxes, parse each
      return parse( $1 ) + parse( $2 )
    when /^(\[)(.+?)(\])$/, /^(\()(.+?)(\))$/, /^(\{)(.+?)(\})$/   # just one box, parse contents
      return $1 + parse($2) + $3
    when /^(\[|\(|\{)(\[.+?\]$|\(.+?\)$|\{.+?\}$|B$)/ # extra opening bracket
      open, rest = $1, $2
      if ( rest =~ /^(\[.+?\]|\(.+?\)|\{.+?\})((\[.+?\]|\(.+?\)|\{.+?\})+)$/ )
        # can't correct if there are more than two possible boxes, so signal error and show possible closures
        raise UncorrectableError.new( open, rest, @spec )
      else
        # there's only one place the missing bracket can go, so put it there and keep parsing
        return open + parse( rest ) + (open == "["? "]": open == "("? ")": "}")
      end
    when /^(\[.+?\]|\(.+?\)|\{.+?\}|B)(\]|\)|\})$/ # extra closing bracket
      rest, close = $1, $2
      if ( rest =~ /^(\[.+?\]|\(.+?\)|\{.+?\})((\[.+?\]|\(.+?\)|\{.+?\})+)$/ )
        # can't correct if there are more than two possible boxes, so signal error and show possible closures
        raise UncorrectableError.new( close, rest, @spec )
      else
        # there's only one place the missing bracket can go, so put it there and keep parsing
        return (close == "]"? "[": close == ")"? "(": "{") + parse( rest ) + close
      end
    else
      # no clue, give up
      raise UncorrectableError.new( nil, nil, @spec )
    end
  end

end

class UncorrectableError < RuntimeError
  # shows errors that can't be corrected.
  # err can have one of three value:
  # nil means we don't know what to do about this error, so it just prints spec and admits defeat
  # an opening bracket means we lack a closing bracket but don't know where to put it, so print possibilities
  # a closing bracket is vice versa.
  # context is the part of the string where the error could be (and is ignored when err is nil)
  # spec is the total string
  def initialize( err, context, spec )
    @err = err
    @spec = spec
    if @err
      @context = context
      # split into boxes to show where missing bracket could go
      @possibles = @context.scan(/\[.+?\]|\(.+?\)|\{.+?\}/)
      # missing closing bracket
      if @err =~ /\[|\(|\{/ then
        @spec = @spec.gsub( (err + context), "*" )
        @fix = @err == "["? "]": @err == "("? ")": "}"
        @prompts = @err + @possibles.collect { |n| n + @fix + "?" }.to_s
      # missing opening bracket, which is pretty much the same apart from the order of things
      else
        @spec = @spec.gsub( (context + err), "*" )
        @fix = @err == "]"? "[": @err == ")"? "(": "{"
        @prompts = @possibles.collect { |n| @fix + "?" + n }.to_s + @err
      end
    end
  end

  def show
    if @err
      print "#{@spec.gsub( "*", @prompts )}\n"
    else
      print "#{@spec} just doesn't make sense at all\n"
    end
  end

end


box = BracketParser.new( ARGV.first.to_s )
box.qc
