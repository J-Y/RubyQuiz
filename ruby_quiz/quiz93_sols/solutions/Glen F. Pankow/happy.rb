#! /usr/bin/ruby
#
#  quiz-93  --  Ruby Quiz #93.
#
# See the Ruby Quiz #93 documentation for more information
# (http://www.rubyquiz.com/quiz93.html).
#
# I do the basic quiz, and in addition try to come up with meaningful
# unhappiness values and constuct interesting path strings.  See the
# documentation to findHappiness() below for more information.
#
#  Glen Pankow      09/02/06
#


# class Integer
class Fixnum

    #
    # Map from digit characters to the squares of integer values.
    #
    @@squares = { '0' =>   0, '1' =>   1, '2' =>   4, '3' =>   9, '4' =>  16,
                  '5' =>  25, '6' =>  36, '7' =>  49, '8' =>  64, '9' =>  81,
                  'a' => 100, 'b' => 121, 'c' => 144, 'd' => 169, 'e' => 196,
                  'f' => 225, 'g' => 256, 'h' => 289, 'i' => 324, 'j' => 361,
                  'k' => 400, 'l' => 441, 'm' => 484, 'n' => 259, 'o' => 576,
                  'p' => 625, 'q' => 676, 'r' => 729, 's' => 784, 't' => 841,
                  'u' => 900, 'v' => 961, 'w' =>1024, 'x' =>1089, 'y' =>1156,
                  'z' =>1225 }

    #
    # Return the sign of the current number.  That is, return 1 for non-
    # negative numbers, and -1 otherwise.
    #
    def sign
        self >= 0? 1 : -1
    end

    #
    # Return the sum of the squares of the digits of the current number in
    # the base <base>.
    #
    def sqrSum(base = 10)
        to_s(base).split(//).inject(0) { |sum, dig| sum += @@squares[dig] }
    end

    #
    # Return a string representation of the current number in the base <base>.
    # If the base is not decimal (and the number is not small), we tack onto
    # the string representation its decimal representation in curly braces.
    #
    def inspect(base = 10)
        return to_s(base) \
          if (   (base == 10) \
              || ((self >= 0) && (self < 10) && (self < base)) \
              || ((self < 0) && (-self < 10) && (self < base)))
        "#{to_s(base)}{#{to_s(10)}}"
    end

end



#
# happiness = findHappiness(n, base = 10, stack = nil)
#
# Find and return the number <n>'s (un)happiness in the base <base>.  <stack>
# is an optional stack of numbers in a chain of digit-square-sums (assumedly
# also computed in <base>) that lead to <n>.
#
# These globals are updated as a side effect:
#    $happinesses  --  [Array] the (un)happiness value for <n> indexed by <n>
#        (and so forth for all subsequent numbers in the digit-square-sum chain
#        created from <n>).
#    $paths  --  [Array] path representation string of the digit-square-sum
#        chain created from <n>, indexed by <n> (and so forth ...).
#    $cycledNs  --  [Hash] those <n>s that form self-contained unhappy loops.
# These globals are assumed to exist (and cleared for calculations in each
# base).  I.e., these or similar commands should be run prior to a new set of
# calculations:
#    $happinesses = [ ]
#    $happinesses[1] = 0
#    $paths = [ ]
#    $paths[1] = '1 (happy!)'
#    $cycledNs = { }
#
# We also take pains to compute meaningful unhappiness values and to construct
# useful path strings (hence the complexity of this method).  And thus, all
# (un)happiness values here are treated as counts of the number of steps needed
# before we reach 1 (happiness!) or we reach a loop (unhappy).  Note that the
# count for happy numbers is one more than the rank of the number as specified
# by the Quiz.
#
# Regarding unhappiness, we want to note their values from the first number
# seen that forms a loop.  This is somewhat tricky, due to the fact that these
# first numbers seen vary in shared loops created from different source numbers.
# So when we see a loop, we generate all shared forms of the loop.  E.g. the
# loop [ 89 => 145 => 42 => 20 => 4 => 16 => 37 => 58 => 89 ] is equivalent to
# the loop [ 4 => 16 => 37 => 58 => 89 => 145 => 42 => 20 => 4 ] (and likewise
# for all of the other numbers seen in the loop).
#
def findHappiness(n, base = 10, stack = nil)

    #
    # If we've already found n's happiness, just return it.
    #
    return $happinesses[n] unless ($happinesses[n].nil?)

    #
    # Look for loops up the stack.  If we find one, note its unhappiness, and
    # likewise for its sister loops.
    #
    unless (stack.nil?)
        (stack.size-2).downto(0) do |i|
            if (stack[i] == n)      # ooh! found a loop!!!
                loopLen = i - stack.size + 1
                i.upto(stack.size-2) do |j|
                    jN = stack[j]
                    $happinesses[jN] = loopLen
                    $paths[jN] = '[ ' + jN.inspect(base)
                    (j+1).upto(stack.size-2) { |k|
                       $paths[jN] << ' => ' << stack[k].inspect(base) }
                    (stack.size-1).upto(j-loopLen) { |k|
                       $paths[jN] << ' => ' << stack[k+loopLen].inspect(base) }
                    $paths[jN] << ' ]'
                    $cycledNs[jN] = true
                end
                return loopLen
            end
        end
    end

    #
    # Our happiness depends on the happiness of the next digit-square-sum in
    # the chain.  Push ourself on the stack and recurse if the next happiness
    # isn't yet known.
    #
    nextN = n.sqrSum(base)
    nextHappiness = $happinesses[nextN]
    if (nextHappiness.nil?)
        stack = [ ] if (stack.nil?) ;  stack << n
        nextHappiness = findHappiness(nextN, base, stack)
        return $happinesses[n] unless ($happinesses[n].nil?)
    end

    #
    # And increment/decrement the happiness value from the next in the chain.
    #
    if (nextHappiness == 0)     # happy?
        $happinesses[n] = 1
        $paths[n] = n.inspect(base) + ' -> 1 (happy!)'
    else
        $happinesses[n] = nextHappiness + nextHappiness.sign
        # if ($cycledNs.has_key?(nextN))
        #     $paths[n] \
        #       = "#{n.inspect(base)} -> #{nextN.inspect(base)} [loops!]"
        # else
            $paths[n] = n.inspect(base) + ' -> ' + $paths[nextN]
        # end
    end
    $happinesses[n]
end


# 2.upto(36) do |base|
 10.upto(10) do |base|
    # maxN = base * base
    maxN = 100000
    print "\nFor the base #{base}, 1 <= n <= #{maxN}:\n"
    $happinesses = [ ]
    $happinesses[1] = 0
    $paths = [ ]
    $paths[1] = '1 (happy!)'
    $cycledNs = { }
    happiestN = 0
    happiestHappiness = 0
    saddestN = 0
    saddestHappiness = 0
    numHappies = 0
    numUnhappies = 0
    (1..maxN).each do |n|
        happiness = findHappiness(n, base)
        printf "%9s (happiness %3d)  ->  %s\n",
          n.inspect(base), happiness, $paths[n]
        numHappies += 1 if (happiness >= 0)
        numUnhappies += 1 if (happiness < 0)
        happiestN, happiestHappiness = n, happiness \
          if (happiness > happiestHappiness)
        saddestN, saddestHappiness = n, happiness \
          if (happiness < saddestHappiness)
    end
    print \
      "For the base #{base} (numbers 1..#{maxN.inspect(base)}):\n" \
      "   We saw #{numHappies} happy numbers and #{numUnhappies} unhappy ones.\n"
    print "      *** ALL HAPPY ***\n" if (numUnhappies == 0)
    print "      !!! ALL UNHAPPY !!!\n" if (numHappies == 0)
    print \
      "   The happiest number is #{happiestN.inspect(base)}" \
      " with a happiness rank of #{happiestHappiness-1}!\n" \
      "      #{happiestN.inspect(base)}:  #{$paths[happiestN]}\n" \
      if (numHappies > 0)
        # Note: we say happiestHappiness-1 here to convert from my happiness
        # count (number of steps to 1) and the Quiz' rank (number of numbers
        # between n and 1).
    print \
      "   The saddest number is #{saddestN.inspect(base)}" \
      " with a happiness rank of #{saddestHappiness}!\n" \
      "      #{saddestN.inspect(base)}:  #{$paths[saddestN]}\n" \
      if (numUnhappies > 0)
    # if (numUnhappies > 0)
    #    print "   The unhappy cycles seen:\n"
    #    $cycledNs.keys.sort.each do |n|
    #       printf "   %8s is a cycle:  %s\n", n.inspect(base), $paths[n]
    #     end
    # end
end

#
# Sample output:
#
# For the base 5, 1 <= n <= 25:
#         1 (happiness   0)  ->  1 (happy!)
#         2 (happiness  -3)  ->  2 -> [ 4 => 31{16} => 4 ]
#         3 (happiness  -4)  ->  3 -> 14{9} -> 32{17} -> [ 23{13} => 23{13} ]
#         4 (happiness  -2)  ->  [ 4 => 31{16} => 4 ]
#     10{5} (happiness   1)  ->  10{5} -> 1 (happy!)
#     11{6} (happiness  -4)  ->  11{6} -> 2 -> [ 4 => 31{16} => 4 ]
#     12{7} (happiness   2)  ->  12{7} -> 10{5} -> 1 (happy!)
#     13{8} (happiness  -4)  ->  13{8} -> 20{10} -> [ 4 => 31{16} => 4 ]
#     14{9} (happiness  -3)  ->  14{9} -> 32{17} -> [ 23{13} => 23{13} ]
#    20{10} (happiness  -3)  ->  20{10} -> [ 4 => 31{16} => 4 ]
#    21{11} (happiness   2)  ->  21{11} -> 10{5} -> 1 (happy!)
#    22{12} (happiness  -5)  ->  22{12} -> 13{8} -> 20{10} -> [ 4 => 31{16} => 4 ]
#    23{13} (happiness  -1)  ->  [ 23{13} => 23{13} ]
#    24{14} (happiness  -4)  ->  24{14} -> 40{20} -> [ 31{16} => 4 => 31{16} ]
#    30{15} (happiness  -4)  ->  30{15} -> 14{9} -> 32{17} -> [ 23{13} => 23{13} ]
#    31{16} (happiness  -2)  ->  [ 31{16} => 4 => 31{16} ]
#    32{17} (happiness  -2)  ->  32{17} -> [ 23{13} => 23{13} ]
#    33{18} (happiness  -1)  ->  [ 33{18} => 33{18} ]
#    34{19} (happiness   2)  ->  34{19} -> 100{25} -> 1 (happy!)
#    40{20} (happiness  -3)  ->  40{20} -> [ 31{16} => 4 => 31{16} ]
#    41{21} (happiness  -3)  ->  41{21} -> 32{17} -> [ 23{13} => 23{13} ]
#    42{22} (happiness  -4)  ->  42{22} -> 40{20} -> [ 31{16} => 4 => 31{16} ]
#    43{23} (happiness   2)  ->  43{23} -> 100{25} -> 1 (happy!)
#    44{24} (happiness  -6)  ->  44{24} -> 112{32} -> 11{6} -> 2 -> [ 4 => 31{16} => 4 ]
#   100{25} (happiness   1)  ->  100{25} -> 1 (happy!)
# For the base 5 (numbers 1..100{25}):
#    We saw 7 happy numbers and 18 unhappy ones.
#    The happiest number is 12{7} with a happiness rank of 1!
#       12{7}:  12{7} -> 10{5} -> 1 (happy!)
#    The saddest number is 44{24} with a happiness rank of -6!
#       44{24}:  44{24} -> 112{32} -> 11{6} -> 2 -> [ 4 => 31{16} => 4 ]
#
# For the base 10 (numbers 1..100000):
#    ...
#    We saw 14377 happy numbers and 85623 unhappy ones.
#    The happiest number is 78999 with a happiness rank of 6!
#       78999:  78999 -> 356 -> 70 -> 49 -> 97 -> 130 -> 10 -> 1 (happy!)
#    The saddest number is 15999 with a happiness rank of -19!
#       15999:  15999 -> 269 -> 121 -> 6 -> 36 -> 45 -> 41 -> 17 -> 50 -> 25
#              -> 29 -> 85 -> [ 89 => 145 => 42 => 4 => 16 => 37 => 58 => 89 ]
#
### No bases in 2..36 other than 2 and 4 were happy.
