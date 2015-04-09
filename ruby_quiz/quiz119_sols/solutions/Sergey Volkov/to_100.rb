#!/usr/bin/ruby
#
# Q119 Solution by Sergey Volkov
# Accept
#   - an arbitrary number and ordering of digits,
#   - an arbitrary set of operators (but allowing
#     the same operator more than once),
#   - an arbitrary target number
# Output every possible equation that can be formed,
# and the actual result of that equation.
# The equation that results in target number have
# stars around it.
# At the end, print out the number of formulae
# that were possible.
#
require 'rubygems'
require 'facets/core/enumerable/permutation'

# all possible unique permutations
def op_seqs a
    res = Hash.new
    a.each_permutation{ |pe|
        res[pe] = true
    }
    res.keys
end

# generate all expressions without reordering,
# recursive implementation;
# I could have implemented Array#each_incut( arr )
# to get more generic solution, but I'm too lazy..
# Will it be better to avoid recursion?
# Not required for this quiz, but must for generic method.
# Does anybody knows elegant nonrecursive implementation? Please show me.
def incut_all digs, opcs, scurr='', &block
    if digs.empty? || opcs.empty?
        # result string
        block[ %/#{scurr}#{digs}#{opcs.pack('C*')}/ ]
        return
    end
    # extend with digit
    incut_all digs[1..-1], opcs, scurr+digs[0].to_s, &block
    # extend with operator
    incut_all digs, opcs[1..-1], scurr+opcs[0].chr, &block
end

# output all possible equations
def show_all digits, opers, target
    # validate arguments
    a_digs = digits.scan(/./).map{ |d| Integer( d ) }
    fail "invalid operator, only [-, +, *, /] allowed" unless %r|^[-+*/]+| =~ opers
    a_ops  = opers.unpack('C*')
    n_targ = Integer( target )

    count = 0 # equation counter
    # operators char set
    op_cs = %/[#{ Regexp.quote a_ops.uniq.pack('C*') }]/
    # Regexp for 'incorrect' expression
    bad_exp_rx = %r/^#{op_cs}|#{op_cs}{2}|#{op_cs}$/o
    for op_seq in op_seqs( a_ops )
        incut_all( a_digs, op_seq ){ |exp|
            next if bad_exp_rx =~ exp
            # beautify expression
            exp.gsub!( %r/#{op_cs}/, %q/ \0 / )
            # evaluate expression
            next unless val = eval( exp ) rescue nil
            s = %/#{exp} = #{val}/
            sep = (val == n_targ) && '*'*s.size
            puts sep if sep
            puts s
            puts sep if sep
            count += 1
        }
    end
    puts %/#{count} possible equations tested/
end

# Arguments accepted:
# an arbitrary number and ordering of digits
digits = ARGV[0] || '123456789'
# an arbitrary set of operators (but allowing the same operator more
than once)
opers  = ARGV[1] || '+--'
# an arbitrary target number
target = ARGV[2] || 100

# Output all possible equations
show_all( digits, opers, target )
exit
