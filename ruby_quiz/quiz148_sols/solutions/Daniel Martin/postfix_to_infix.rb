#! /usr/bin/env ruby
#
# Accepts RPN using the basic four operations + - / *, as well as
# ^ to denote exponentiation, and outputs infix notation with the
# minimum number of parentheses.  Note that infix exponentiation
# associates to the right, so 2 ^ 2 ^ 2 == 2 ^ (2 ^ 2)

instr = ARGV.join(' ');
s = instr.dup
s.gsub!(/(\d+(\.\d*)?)/, '<n:\1>')
s.gsub!(/\s/,'')

# Data structures?  We don't need no stinkin' data structures.
# Postfix expression to infix expression via regular expressions.

while s =~ /<.*</ do
  f = false
  f |= s.gsub!(%r{<.:([^>]*)><.:([^>]*)>\+}, '<+:\1 + \2>')

  f |= s.gsub!(%r{<.:([^>]*)><[+-]:([^>]*)>-}, '<-:\1 - (\2)>')
  f |= s.gsub!(%r{<.:([^>]*)><[^+-]:([^>]*)>-}, '<-:\1 - \2>')

  f |= s.gsub!(%r{<[+-]:([^>]*)><[+-]:([^>]*)>\*}, '<*:(\1) * (\2)>')
  f |= s.gsub!(%r{<[+-]:([^>]*)><[^+-]:([^>]*)>\*}, '<*:(\1) * \2>')
  f |= s.gsub!(%r{<[^+-]:([^>]*)><[+-]:([^>]*)>\*}, '<*:\1 * (\2)>')
  f |= s.gsub!(%r{<[^+-]:([^>]*)><[^+-]:([^>]*)>\*}, '<*:\1 * \2>')

  f |= s.gsub!(%r{<[+-]:([^>]*)><[*/+-]:([^>]*)>/}, '</:(\1) / (\2)>')
  f |= s.gsub!(%r{<[^+-]:([^>]*)><[*/+-]:([^>]*)>/}, '</:\1 / (\2)>')
  f |= s.gsub!(%r{<[+-]:([^>]*)><[^*/+-]:([^>]*)>/}, '</:(\1) / \2>')
  f |= s.gsub!(%r{<[^+-]:([^>]*)><[^*/+-]:([^>]*)>/}, '</:\1 / \2>')

  f |= s.gsub!(%r{<[^n]:([^>]*)><[^n^]:([^>]*)>\^}, '<^:(\1) ^ (\2)>')
  f |= s.gsub!(%r{<[^n]:([^>]*)><[n^]:([^>]*)>\^}, '<^:(\1) ^ \2>')
  f |= s.gsub!(%r{<n:([^>]*)><[^n^]:([^>]*)>\^}, '<^:\1 ^ (\2)>')
  f |= s.gsub!(%r{<n:([^>]*)><[n^]:([^>]*)>\^}, '<^:\1 ^ \2>')
  unless f
    raise "Malformed RPN string: '#{instr}' (s is #{s})"
  end
end

s.gsub!(/<.:(.*)>/, '\1')
puts s

__END__
