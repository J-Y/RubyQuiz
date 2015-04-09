#!/usr/bin/env ruby
#
# compiler.rb - Byte-code compiler for simple arithmetic expressions
#
# Lou Scoras <louis.j.scoras@gmail.com>
# Wed Nov 8 20:33 EST 2006
#
# Here's my solution for Rubyquiz 100. Nothing too fancy on this one: I went
# for trying to make the shunting algorith as readable as possile.
#
# As for the parsing, StringScanner is very nice, although it might have been
# overkill for this problem.
#
# Thanks again to Ross and James for another fun quiz.

require 'enumerator'
require 'interp'
require 'optparse'
require 'strscan'

class Token
attr_reader :type, :value

def initialize(value)
  @value = value
end

%w|number lparen rparen op|.each do |a|
  module_eval %{ def #{a}?; false end }
end
end

class Paren < Token
def initialize(value, type)
  super(value)
  @type = type
end
def lparen?; @type == :lparen end
def rparen?; @type == :rparen end
end

class Number < Token
def initialize(value)
  super(value.to_i)
end

def to_bc
  code, fmt = ((-32768..32767).include? value) ? [0x01, 'n'] : [0x02, 'N']
  [code, *[value].pack(fmt).to_enum(:each_byte).to_a]
end
def number?; true end
end

class Op < Token
attr_reader :precedence

CodeTable = [:+, :-, :*, :**, :/, :%].to_enum(:each_with_index).
            inject({}) {|h, (op,i)| h[op] = i + 0x0a; h}

def initialize(value,assoc,prec)
  super(value.to_sym)
  @assoc, @precedence = assoc, prec
end

%w|assoc lassoc rassoc|.each do |a|
  module_eval %{
    def #{a}?
      @assoc == :#{a}
    end
  }
end

def op?; true end

def to_bc
  CodeTable[value]
end
end

class Compiler
class << self

  def compile(exp)
    shunting_yard(exp).collect {|t| t.to_bc }.flatten
  end

  def tokens(i)
    input = StringScanner.new(i)
    until input.eos?
      case
      when t = input.scan(/\d+/)    :  yield Number.new(t)
      when t = input.scan(/[(]/)    :  yield Paren.new(t, :lparen)
      when t = input.scan(/[)]/)    :  yield Paren.new(t, :rparen)
      when t = input.scan(/\*\*/)   :  yield Op.new(t, :rassoc, 3)
      when t = input.scan(%r<[%/]>) :  yield Op.new(t, :lassoc, 2)
      when t = input.scan(%r<[*]>)  :  yield Op.new(t, :assoc,  2)
      when t = input.scan(%r<[-]>)  :  yield Op.new(t, :lassoc, 1)
      when t = input.scan(%r<[+]>)  :  yield Op.new(t, :assoc,  1)
      when input.scan(/\s+/)        :  # skip ws
      else
        raise RuntimeError, "Parse Error: near '#{input.peek(8)}'"
      end
    end
  end

  def shunting_yard(s)
    stack, queue     = [] , []
    last_tok, negate = nil, false  # detect unary minus
    tokens(s) do |token|
      case
      when token.number?
        queue << (negate ? Number.new(-token.value) : token)
        negate = false
      when token.op?
        if !last_tok || (last_tok.op? || last_tok.lparen?) &&
                        (token.value == :-)
          negate = true
        else
          while stack.size > 0 and stack.last.op?
            other_op = stack.last
            if ( token.assoc? || token.lassoc? and
		  token.precedence <= other_op.precedence) ||
                (token.rassoc? and token.precedence < other_op.precedence)
              queue << stack.pop
            else
              break
            end
          end
          stack << token
        end
      when token.lparen?
        stack << token
      when token.rparen?
        while stack.size != 0 and op = stack.pop
          break if op.lparen?
          queue << op
        end
      end
      last_tok = token
    end
    stack.reverse.each do |op|
      queue << op
    end
    queue
  end

  def to_rpn(exp)
    shunting_yard(exp).collect{|t| t.value}.join(' ')
  end

  DCBin = '/usr/bin/dc'

  def dc_eval(exp)
    if File.executable?(DCBin)
      exp = to_rpn(exp)
      IO.popen(DCBin, "w+") do |f|
        f.write(exp.gsub(/\*\*/, '^') + ' p')
        f.close_write
        f.read
      end
    end
  end

end
end


if $0 == __FILE__
opt = OptionParser.new do |opt|
  opt.banner = "Usage: #$0 compile_method"
  opt.separator ''

  opt.on('-c', '--compile [expression]',
          'prints bytecode sequence for [expression]') do |exp|
    p Compiler.compile(exp)
  end

  opt.on('-d', '--dc-eval [expression]',
          'trys to evaluate [expression] using dc(1)') do |exp|
    puts Compiler.dc_eval(exp)
  end

  opt.on('-i', '--interpret [expression]',
      'uses the byte-code interpreter to process [expression]') do |exp|
    puts Interpreter.new(Compiler.compile(exp)).run
  end

  opt.on('-r', '--show-rpn [expression]',
      'prints out an RPN translated version of [expression]') do |exp|
    puts Compiler.to_rpn(exp)
  end

  opt.on('-h', '--help') { puts opt }
end
if ARGV.empty?
  puts opt
else
  opt.parse(ARGV)
end
end
