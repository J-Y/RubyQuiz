#!/usr/bin/env ruby -w
# ruby119.rb -- solves combinatorial arithmetic puzzles
# Released 2007 with no license by Harrison Reiser

require 'combinatorics'
require 'getoptlong'

def dispense_advice
  puts "Usage: #{$0} [OPTIONS] digits ops = sum"
  puts "  e.g. #{$0} 123456789 + - - = 100"
  puts "equiv: #{$0} 123 - 45 - 67 + 89 = 100"
  puts
  puts "Will attempt to search for a combination of the digits and"
  puts "operators given that produce the sum. Each solution uses"
  puts "each digit once and includes all given operator types."
  puts
  puts "Operators recognized: +, -, *, /, . (decimal point)"
  puts "Standard operator precedence is used: (*, /) over (+, -)"
  puts
  puts "Options:"
  puts "  --help, -h"
  puts "    Shows this message."
  puts "  --permute-digits, -p"
  puts "    Allows the given digits to be combined arbitrarily."
  puts "  --no-permute-digits, -P"
  puts "    Maintains the given order of the digits. (default)"
  puts "  --repeat-ops, -r"
  puts "    Uses arbitrary (1..*) operator multiplicity. (default)"
  puts "  --no-repeat-ops, -R"
  puts "    Maintains each of the given operators' multiplicities."
  puts "  --unary-minus, -n"
  puts "    Allows the use of '-' as negation of the first number."
  puts "  --no-unary-minus, -N"
  puts "    Disallows the use of the negation operator. (default)"
  exit
end

opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--permute-digits', '-p', GetoptLong::NO_ARGUMENT],
  ['--no-permute-digits', '-P', GetoptLong::NO_ARGUMENT],
  ['--repeat-ops', '-r', GetoptLong::NO_ARGUMENT],
  ['--no-repeat-ops', '-R', GetoptLong::NO_ARGUMENT],
  ['--unary-minus', '-n', GetoptLong::NO_ARGUMENT],
  ['--no-unary-minus', '-N', GetoptLong::NO_ARGUMENT]
)

repeat_ops = true
unary_minus = false
permute_digits = false

opts.each do |opt, arg|
  case opt
  when '--help'
    dispense_advice
  when '--permute-digits'
    permute_digits = true
  when '--no-permute-digits'
    permute_digits = false
  when '--repeat-ops'
    repeat_ops = true
  when '--no-repeat-ops'
    repeat_ops = false
  when '--unary-minus'
    unary_minus = true
  when '--no-unary-minus'
    unary_minus = false
  end
end

dispense_advice if ARGV.length == 0

digits = []
operators = []

arg_str, sum = ARGV.join.split(/=/)
sum = sum.to_i
dispense_advice if sum == 0

arg_str.each_byte do |byte|
  case byte
  when ?0..?9
    digits << byte.chr
  when ?-, ?+, ?*, ?/
    operators << byte.chr
  else
    dispense_advice
  end
end

operators.uniq! if repeat_ops
count = 0
hits = 0

ops_send_args  = repeat_ops ? [:each_tuple, 0] : [:each_unique_permutation]
digits_message = permute_digits ? :each_partition : :each_ordered_partition

digits.send(digits_message) do |part|
  next unless repeat_ops or part.length == operators.length + 1
  part = part.map { |x| x.join } if part.first.respond_to?(:join)
  
  ops_send_args[1] = part.length - 1 if repeat_ops
  operators.send(*ops_send_args) do |tuple|    
    expr = part.zip(tuple).join(' ')
    if eval(expr.gsub(/ (\d*) /, ' \1.0 ').gsub(' . ', '.')) == sum
      puts "#{expr}= #{sum}"
      hits += 1
    end
    count += 1
    
    if unary_minus and operators.include?('-')
      num = part[0].to_i
      part[0] = (-num).to_i
      redo if num > 0
    end
  end
  
  if permute_digits
    part << part.shift
    redo unless part.first == part.min
  end
end

print "#{count} equation#{count == 1 ? '' : 's'} searched, ",
      "#{hits} solution#{hits == 1 ? '' : 's'} found.\n"
