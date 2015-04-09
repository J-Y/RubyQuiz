#!/usr/bin/env ruby

# Yes, the lexer class is probably overkill, but I had it sitting around from
# another project and code reuse is a good thing =)

# I originally was going to tinker with this until the output ensured that
# each braket is immediately wrapped in a box by iteself, but I think this is
# proably good enough--this works for both of the example erroneous inputs in
# the quiz description--and it's already getting pretty long.

require 'strscan'

class Lexer
 class << self
   def add_rule(regex, token_type = nil, &block)
     @rules ||= []
     block  ||= lambda { |match, token| [token, match] }
     @rules << [ regex, token_type, block ]
   end

   def each_rule
     @rules.each do |rule|
       yield *rule
     end
   end
 end

 def initialize(input)
   @scanner = StringScanner.new(input)
   @tokens  = Array.new()
   @error_context_length = 20
 end

 attr_accessor :error_context_length

 def tokens()
   until @scanner.eos?
     @tokens << find_match()
   end
   @tokens.compact
 end

 def find_match()
   self.class.each_rule do |regex, token, block|
     if (@scanner.scan(regex)) then
       return block.call(@scanner.matched, token)
     end
   end
   raise Exception,
      "Parse error:\n"                      +
      'Can not tokenize input near "'       +
       @scanner.peek(@error_context_length) + '"'
 end
end

class BoxLexer < Lexer
 add_rule(/[\[({]/, :begin_box)
 add_rule(/[\])}]/, :end_box)
 add_rule(/b/i,     :bracket)
end

class Parser
 @@matching_symbol = {
   '(' => ')', ')' => '(',
   '[' => ']', ']' => '[',
   '{' => '}', '}' => '{'
 }

 def initialize input
   @tokens = BoxLexer.new(input).tokens
   @stack  = []
   @corrected_stream = []
 end

 def parse
   while @tokens.size > 0
     @current_token = @tokens.shift
     dispatch_event
   end
   if (@current_token[0] != :end_box)
     notify "!Wrapping all parts in wood '{'"
     @corrected_stream.unshift [:begin_box, '{']
     @corrected_stream << [:end_box, '}']
   end
 end

 attr_reader :corrected_stream

 private

 def notify mesg
   print '  ' * @stack.length
   puts mesg
 end

 def dispatch_event
   case @current_token[0]
     when :begin_box
       begin_event
     when :bracket
       bracket_event
     when :end_box
       end_event
   end
 end

 def begin_event
   value = @current_token[1]
   notify "Found begin box '#{value}'"
   @stack.push value
   @corrected_stream << @current_token
 end

 def bracket_event
   notify "Found a bracket"
   if (@tokens.length < 1) then
     premature_end
   else
     if (@tokens[0][0] != :end_box) then
       notify "! Bracket must be followed by an ending box"
       fix = guess_best_fix
       notify "! Attempting to fix by adding end box: '#{fix}'"
       @tokens.unshift [:end_box, fix]
     end
     @corrected_stream << @current_token
   end
 end

 def end_event
   value = @current_token[1]
   symbol = @@matching_symbol[@stack.pop]
   notify "Found end box '#{value}'"
   if (value != symbol) then
     if symbol then
       notify "! Bad match: Expecting closed '#{symbol}' got '#{value}'"
       notify "! Attempting to fix by adding '#{symbol}'"
       @tokens.unshift @current_token
       @corrected_stream << [:end_box, symbol]
     else
       premature_end
     end
   else
     @corrected_stream << @current_token
   end
 end

 def guess_best_fix
   fix = @@matching_symbol[@stack[-1]]
   if (!fix) then
     notify "! Wow, we really screwed this one up."
     notify "! Use soft packaging ')' because we are cheap ;-)"
     fix = ')'
   end
   fix
 end

 def premature_end
   value = @current_token[1]
   new_sym = @@matching_symbol[value]
   notify "! Premature end of box: found extra '#{value}'"
   notify "! Attempting to fix by wrapping entire payload in '#{new_sym}'"
   @corrected_stream.unshift [:begin_box, new_sym]
   @corrected_stream << [:end_box, value]
 end
end

if (ARGV.length < 1) then
 $stderr.puts "Usage #{__FILE__} box_string"
 exit
end

parser = Parser.new(ARGV[0])
parser.parse
puts parser.corrected_stream.collect{|t| t.last}.join('')
