#!/usr/bin/env ruby
#
#  Created by Vasil Vangelovski on 2007-12-05.
#  Copyright (c) 2007. All rights reserved.
#
# Solution for ruby quiz 148
# Fixed a bug that occured with some expressions


class String

  #checks if the string is an operator
  def op?
    return (self=='+')||(self=='-')||(self=='*')||(self=='/');
  end

  #returns true only for strings that
  #represent integer or decimal numbers
  def number?
    #just  regex
    #most likely faster
    #than exception handling
    match =  /\b[0-9]+([.]{1}[0-9]+){0,1}\b/.match(self)
    if match.nil?
      return false
    else
      return match[0]==self
    end
  end

end


def post_inf(expr)

  tokens = expr.split(' ')
  #the postfix->infix algo goes like this
  stack = []
  tokens.each {|token|
    if token.number?
      stack.push(token)
    elsif token.op?
      string_top = stack.pop
      string_bottom = stack.pop
      #simple logic regarding operator precedance
      exp = "#{string_bottom}#{token}#{string_top}"
      exp = '('+exp+')' if (token =='+')||(token=='-')
      stack.push(exp)
    else
      #if it's not a number nor operator it's no valid
      puts "Invalid input!"
      exit(1)
    end
  }
  return stack.to_s
end

puts post_inf(ARGV[0])


#Some test output
post_inf('56 34 213.7 + * 678 -') # => "(56*(34+213.7)-678)"
post_inf('1 56 35 + 16 9 - / +') # => "(1+(56+35)/(16-9))"
post_inf('43.55 3.2 + 23 5 - /') # => "(43.55+3.2)/(23-5)"
