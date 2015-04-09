#!/usr/bin/env ruby

# Solution to Ruby Quiz #148 (see http://www.rubyquiz.com/quiz148.html)
# by Pawel Radecki (pawel.j.radecki@gmail.com).

# Note1: There may be couple of different and correct postfix to infix
# transformations but this program only gives one and ignores others.
#
# Example:
# postfix: 1 2 + 4 * 5 + 3 -
# infix: (1 + 2) * 4 + 5 - 3
# infix: (1+2)*4+5-3
# infix: 5 + (1 + 2) * 4 - 3
# infix: 5 + 4 * (1 + 2) - 3
# ... (there are more)

# Note2: Unary operators not supported!

# Note3: I don't know why ^ in input argument doesn't work, anybody knows...?

require 'logger'

$LOG = Logger.new($stderr)

#logging
#$LOG.level = Logger::DEBUG #DEBUG
$LOG.level = Logger::ERROR  #PRODUCTION

class PostfixEquation < String

    private
    @@OPERATOR_PRIORITIES = {
                            'V' => 2,
                            '**' => 2,
                            '*' => 2,
                            '/' => 2,
                            '+' => 3,
                            '-' => 3
                        }

    def normalize_expression (expression)
        a = expression.split

        $LOG.debug("array: #{a}")
        $LOG.debug("#{a[0]} #{a[2]} #{a[1]}")

        @operator_stack.push(a[2])

        $LOG.debug("@operator_stack #{@operator_stack}")

        s = "#{a[0]} #{a[2]} #{a[1]}"
        if @operator_stack.length>1 && @@OPERATOR_PRIORITIES[@operator_stack[-2]]<@@OPERATOR_PRIORITIES[a[2]]
            s = "(#{s})"
        end

        if @two_branches
            @operator_stack.pop
        end

        #hack to resolve situation with two complex expressions forming another
        if a[0] =~/[a-z]+/ && a[1] =~/[a-z]+/
            @two_branches = true
        else
            @two_branches = false
        end

        return s
    end

    public
    def initialize(equation)
        @string = super.to_str
        @label = "a"
        @expressions = {}
        @operator_stack = []
        @two_branches = false
    end

    def to_infix
        $LOG.debug("string: #{@string}")

        while (true)
            $LOG.debug("string: #{@string}")
            $LOG.debug("string lenth: #{@string.length}")

            #look for "(number or letter(s)) (number or letter(s)) operator" pattern
            #where number is chain of any digit and . (dot) characters
            #letter(s) is one or more letters
            #and operator is one of following characters: + - * / p r
            @string =~ /([0-9\.]+|[a-z]+)\s([0-9\.]+|[a-z]+)\s((\*\*)|(V)|\+|\*|\/|-)/
            $LOG.debug("pattern match: #{$`}<<#{$&}>>#{$'}")

            # if the the expression is not valid
            if ($&==nil || $&=="") && @string.length>1
               $LOG.error("Stack is not empty!")
               raise Exception.new("Stack is not empty!")
            end

            @expressions[@label] = $&
            @string = "#{$`}#{@label}#{$'}"
            $LOG.debug("string: #{@string}")
            $LOG.debug("string lenth: #{@string.length}")

            #if it's the last match
            if $`=="" && $'=="" && @string.length==1
               break
            end

            @label.succ!
            $LOG.debug("label: #{@label}")
            $LOG.debug("")

        end

        while (!@expressions.empty?)
            @string.sub!(/([a-z])/) {
                letter = $1.dup
                s = String.new(normalize_expression(@expressions[letter]))
                @expressions.delete(letter)
                s
            }
            $LOG.debug("string: #{@string}")
            $LOG.debug("")
        end

        return @string
    end
end

USAGE = <<ENDUSAGE
Usage:
    postfix_to_infinix.rb 'mathematical equation'

Valid binary operators: + - * / V **
where
    V is a root operator, ex.: 5 V 1 means 5-th root of a number 1
    ** is a power operator, ex.: 2 ** 3 means power with base 2 and
exponent 3

(Unary operators not supported!)

Example:
    postfix_to_infinix.rb '56 34 213.7 + ** 678 -'
ENDUSAGE

if ARGV.length!=1
    puts USAGE
    exit
end

e = PostfixEquation.new(ARGV[0])
begin
    puts e.to_infix
rescue StandardError => err
    puts err
end
