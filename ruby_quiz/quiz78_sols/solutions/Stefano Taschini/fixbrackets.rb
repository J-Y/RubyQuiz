#!/usr/bin/env ruby

=begin rdoc

In order to correct a possibly ill-formed string, the syntactic tree
is constructed starting from the leaves. Well-formed parts of the tree
are inlined in the string, marked by < and >. At the beginning, only
the leaves are marked:

 Bracketing["[(B)(B)]"]
   # => "[(<B>)(<B>)]"

Then, the tree is grown from the leaves:

 Bracketing["[(B)(B)]"].grow_tree
   # => "<[(B)(B)]>"

If the initial string is well-formed the inlined tree includes the
whole string, as in the case above. If the string is ill-formed, then
more than one tree fragmens are left:

 Bracketing['[{(B){(B)(B)}]'].grow_tree
   # => "[{<(B)><{(B)(B)}>]"

Bracketing#fix_tree tries to add the missing bracket so that the
subtrees can be successfully merged:

 Bracketing['[{(B){(B)(B)}]'].grow_tree.fix_tree
   # => "<[{(B)}{(B)(B)}]>"

Bracketing#balance wraps the whole thing up, returning a well-formed
string if the input string was successfully balanced and nil
otherwise.

 Bracketing['[{(B){(B)(B)}]'].balance
   # => "[{(B)}{(B)(B)}]"

Invoking the program with the --test switch runs the test-suite. Else,
the first line of the input is parsed and possibly corrected. The exit
status is set in accordance with the success of the operation.

=end

# Bracketing extends a string in the "bracket language" with inlined
# syntax tree, enclosed in "<" and ">"
class Bracketing < String

  # Replace each open bracket in a string with its closed equivalent.
  def close(string)
    string.tr('([{',')]}')
  end

  # Replace each closed bracket in a string with its open equivalent.
  def open(string)
    string.tr(')]}','([{')
  end

  # Construct a Bracketing object with marked leaves.
  def self.[](string)
    new(string.gsub(/B/,'<B>'))
  end

  # Expand the branches from the leaves.
  def grow_tree
    s = self
    while (z = s.
      gsub(/\(<((?:[^>]|><)*)>\)/) { "<(#{$1.gsub('><','')})>"}.
      gsub(/\[<((?:[^>]|><)*)>\]/) { "<[#{$1.gsub('><','')}]>"}.
      gsub(/\{<((?:[^>]|><)*)>\}/) { "<{#{$1.gsub('><','')}}>"}
    ) != s
      s = z
    end
    z
  end

  # Find all possible corrections to an unbalanced Bracketing object
  # and select the one with lowest complexity.
  def fix_tree
    fixes = []
    scan(/<[^>]*>/) {
      l,m,r = $`,$&,$'
      a, b = l.gsub(/<[^>]*>/,''), r.gsub(/<[^>]*>/,'')
      if close(a + open(b[0,1]||'')).reverse == b
        fixes << self.class.new(l + open(b[0,1]) + m + r).grow_tree
      end
      if a == open(close(a[-1,1]||'') + b).reverse
        fixes << self.class.new(l + m + close(a[-1,1]) + r).grow_tree
      end
    }
    fixes.reject{|x| x['><']}.sort_by{|x| x.complexity}.first || self
  end

  # The complexity is proportional to the variance of the depth over
  # the leaves in the syntactic tree.
  def complexity
    current, data = 0, []
    scan(/./) {|c|
      current += 1 if "{[("[c]
      current -= 1 if "}])"[c]
      data << current if c=="B"
    }
    mean = data.inject{|a,x| a+x} / data.size().to_f
    data.inject(0){|a,x| a + (x-mean) ** 2}
  end

  # Return a balanced string or nil if self cannot be balanced.
  def balance
    z = grow_tree
    while true
      return $1 if z =~ /^<([^>]*)>$/
      s = z
      z = s.fix_tree
      return nil if z == s
    end
  end

end

require 'test/unit'

class Bracketing::Test < Test::Unit::TestCase

  def test_construction
    assert_equal '[{(<B>}{(<B>)(<B>)}]', Bracketing['[{(B}{(B)(B)}]']
  end

  def test_grow_tree
    assert_equal '<{B}><(B)><[B]>', Bracketing['{B}(B)[B]'].grow_tree
    assert_equal '<[{(B)}{(B)(B)}]>', Bracketing['[{(B)}{(B)(B)}]'].grow_tree
    assert_equal '<{(B)}><{(B)(B)}>]', Bracketing['{(B)}{(B)(B)}]'].grow_tree
    assert_equal '[<{(B)}>{(<B><(B)>}]', Bracketing['[{(B)}{(B(B)}]'].grow_tree
  end

  def test_balance
    ref = '[{(B)}{(B)(B)}]'
    assert_equal ref, Bracketing['[{(B)}{(B)(B)}]'].balance
    assert_equal ref, Bracketing['{(B)}{(B)(B)}]'].balance
    assert_equal ref, Bracketing['[(B)}{(B)(B)}]'].balance
    assert_equal ref, Bracketing['[{B)}{(B)(B)}]'].balance
    assert_equal ref, Bracketing['[{(B}{(B)(B)}]'].balance
    assert_equal ref, Bracketing['[{(B){(B)(B)}]'].balance
    assert_equal ref, Bracketing['[{(B)}(B)(B)}]'].balance
    assert_equal ref, Bracketing['[{(B)}{B)(B)}]'].balance
    assert_equal ref, Bracketing['[{(B)}{(B(B)}]'].balance
    assert_equal ref, Bracketing['[{(B)}{(B)B)}]'].balance
    assert_equal ref, Bracketing['[{(B)}{(B)(B}]'].balance
    assert_equal ref, Bracketing['[{(B)}{(B)(B)]'].balance
    assert_equal ref, Bracketing['[{(B)}{(B)(B)}'].balance
    assert_equal nil, Bracketing['(B)}{(B)(B)}]'].balance
  end

end

Test::Unit.run = true
if __FILE__ == $0
  if ARGV[0] == '--test'
    ARGV.pop
    Test::Unit.run = false
  elsif out = Bracketing[gets.chomp].balance
    puts out
    exit 0
  else
    exit 1
  end
end
