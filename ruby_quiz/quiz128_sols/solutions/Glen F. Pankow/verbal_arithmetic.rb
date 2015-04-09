#! /usr/bin/env ruby
#
#  quiz-128  --  Ruby Quiz #128  --  Verbal Arithmetic.
#
#  Usage:  quiz-128 [ -v ] '<equation string>'
#     or:  quiz-128 [ -v ] <addend> <addend> [ <addend> ... ] <sum>
#
#  See the Ruby Quiz #128 documentation for more information
#  (http://www.rubyquiz.com/quiz128.html).
#
#  Glen Pankow      06/17/07        Original version.
#
#  Licensed under the Ruby License.
#
#-----------------------------------------------------------------------------
#
#  I take a slightly different approach to this quiz:  I build up code that
#  kinda-sorta models addition as taught in U.S. elementary schools (taking
#  into account the various constraints of the problem), then eval it.
#
#  And instead of generating permutations of unassigned digits and using
#  recursion for backtracking, I have a single array of digits that is used
#  sort of as a mask (nil entries mark assigned digits) and use Ruby's
#  wonderful magic iterator facility to scan through it.
#
#  $ uname -srmpio
#  Linux 2.6.9-55.ELsmp i686 i686 i386 GNU/Linux
#
#  $ time ./quiz-128 'send + more = money'
#  d = 7, e = 5, y = 2, n = 6, r = 8, o = 0, s = 9, m = 1
#      1   0   1   1
#        s:9 e:5 n:6 d:7
#  +     m:1 o:0 r:8 e:5
#  ---------------------
#    m:1 o:0 n:6 e:5 y:2
#  0.065u 0.003s 0:00.07 85.7%     0+0k 0+0io 0pf+0w
#
#  $ time ./quiz-128 forty ten ten sixty
#  y = 6, n = 0, t = 8, e = 5, r = 7, x = 4, o = 9, i = 1, f = 2, s = 3
#      1   2   1   0
#    f:2 o:9 r:7 t:8 y:6
#            t:8 e:5 n:0
#  +         t:8 e:5 n:0
#  ---------------------
#    s:3 i:1 x:4 t:8 y:6
#  0.029u 0.002s 0:00.03 66.6%     0+0k 0+0io 0pf+0w
#
#  $ time ./quiz-128 eat+that=apple
#  t = 9, e = 8, a = 1, l = 3, h = 2, p = 0
#      1   1   0   1
#            e:8 a:1 t:9
#  +     t:9 h:2 a:1 t:9
#  ---------------------
#    a:1 p:0 p:0 l:3 e:8
#  0.008u 0.002s 0:00.01 0.0%      0+0k 0+0io 0pf+0w
#
#  $ time ./quiz-128 ruby rubber baby buggy bumper
#  y = 0, r = 7, b = 8, e = 1, g = 4, u = 2, a = 3, p = 9, m = 6
#  ...
#  y = 0, r = 7, b = 8, e = 5, g = 4, u = 2, a = 3, p = 9, m = 6
#      1   2   1   2   0
#            r:7 u:2 b:8 y:0
#    r:7 u:2 b:8 b:8 e:5 r:7
#            b:8 a:3 b:8 y:0
#  +     b:8 u:2 g:4 g:4 y:0
#  -------------------------
#    b:8 u:2 m:6 p:9 e:5 r:7
#  0.120u 0.002s 0:00.13 92.3%     0+0k 0+0io 0pf+0w
#


class Array

    #
    # For each non-nil element of the current array, (destructively) set it to
    # nil (i.e., 'marking' it), yield the original value (to the assumed block),
    # and restore it back to what it originally was (i.e., 'unmarking' it).
    #
    # For example, the code:
    #    array = [ 0, nil, 2, 3 ]
    #    p "before: array = #{array.inspect}"
    #    array.unmarkeds { |elem| p "elem = #{elem}, array = #{array.inspect}" }
    #    p "after: array = #{array.inspect}"
    # would print:
    #    before: array = [0, nil, 2, 3]
    #    elem = 0, array = [nil, nil, 2, 3]
    #    elem = 2, array = [0, nil, nil, 3]
    #    elem = 3, array = [0, nil, 2, nil]
    #    after: array = [0, nil, 2, 3]
    #
    def unmarkeds
        (0...size).each do |i|
            next if (at(i).nil?)
            elem = at(i)  ;  self[i] = nil
            yield elem
            self[i] = elem
        end
    end

    #
    # If the <i>-th element of the current array is nil, do nothing.  Otherwise
    # (destructively) set it to nil (i.e., 'marking' it), yield (to the assumed
    # block), and restore it back to what it originally was (i.e., 'unmarking'
    # it).  This is basically the guts of unmarkeds(), and is provided for safe
    # manual element marking.
    #
    def if_unmarked(i)
        return if (at(i).nil?)
        elem = at(i)  ;  self[i] = nil
        yield
        self[i] = elem
    end

    #
    # Note:  typically one might say 'yield elem, self' in these methods, but
    # I don't need them for this application due to Ruby's scoping mechanism.
    #
end


#
# Process the command-line arguments of addend strings and the sum string.
#
verbose = false
addend_strs = [ ]
ARGV.each do |arg|
    if (arg == '-v')
        verbose = true
    else
        arg.split(/[\s+=]+/).each { |term| addend_strs << term }
    end
end
addend_strs = [ 'send', 'more', 'money' ] if (addend_strs.empty?)
sum_str = addend_strs.pop

#
# Split the strings up into their component letters; create some (ugly) code to
# eventually print out a nice table of the addition.
#
table_print_code = 'print " '
(sum_str.length - 1).downto(1) do |i|
    table_print_code << "   \#{carry#{i}}"
end
table_print_code << "\\n\"\n"
addends = [ ]
first_letters = { }
(0...addend_strs.size).each do |i|
    addend_str = addend_strs[i]
    addend_chars = addend_str.split(//).reverse
    addends << addend_chars
    first_letters[addend_chars[-1]] = 1
    table_print_code \
      << 'print "' << ((i < addend_strs.size - 1)? ' ' : '+') \
      << '    ' * (sum_str.length - addend_str.length) \
      << addend_str.gsub(/([a-z])/, ' \1:#{\1}') << "\\n\"\n"
end
table_print_code \
  << 'print "-' << ('----' * sum_str.length) << "\\n\"\n" \
  << 'print " ' << sum_str.gsub(/([a-z])/, ' \1:#{\1}') << "\\n\"\n"
sum_chars = sum_str.split(//).reverse
first_letters[sum_chars[-1]] = 1

#
# Build the addition code.
#
# This, too, is quite ugly and I don't bother to document it, as printing out
# the generated code will probably give one a better idea of how it works than
# my usual verbose documentation (i.e., run this script with -v).
#
seen_chars = { }
code_head = "rem_digs = (0..9).to_a\n"
code_tail = ''
answer_print_code = 'print "'
indent = ''
(0...sum_chars.size).each do |col|
    sum_char = sum_chars[col]
    col_sum_code = "#{indent}carry#{col+1}, #{sum_char} = (carry#{col}"
    addends.inject([ ]) { |dc, addend| dc << addend[col] }.each do |dig_char|
        next if (dig_char.nil?)
        if (seen_chars[dig_char].nil?)
            code_head << "#{indent}rem_digs.unmarkeds do |#{dig_char}|\n"
            code_tail[0,0] = "#{indent}end\n"
            indent << '   '
            seen_chars[dig_char] = 1
            code_head << "#{indent}next if (#{dig_char} == 0)  # leading 0?\n" \
              if (first_letters.has_key?(dig_char))
            col_sum_code[0,0] = '   '   # fix indentation
            answer_print_code << ", #{dig_char} = \#{#{dig_char}}"
        end
        col_sum_code << " + #{dig_char}"
    end
    col_sum_code << ").divmod(10)\n"
    col_sum_code.sub!(/\(carry0 \+ /, '(')
    if (seen_chars[sum_char].nil?)
        code_head << col_sum_code
        code_head << "#{indent}next if (#{sum_char} == 0)  # leading 0?\n" \
          if (first_letters.has_key?(sum_char))
        code_head << "#{indent}rem_digs.if_unmarked(#{sum_char}) do\n"
        code_tail[0,0] = "#{indent}end\n"
        indent << '   '
        seen_chars[sum_char] = 1
        answer_print_code << ", #{sum_char} = \#{#{sum_char}}"
    else
        col_sum_code.sub!(/ = /, '2 = ')
        code_head \
          << col_sum_code \
          << "#{indent}next unless (#{sum_char}2 == #{sum_char})  # inconsistent?\n"
    end
end
answer_print_code.sub!(/\", /, '"\n')
answer_print_code << "\\n\"\n"

#
# And print out the code (if verbose) and run it!
#
code = code_head + answer_print_code + table_print_code + code_tail
print code, "\n" if (verbose)
eval(code)
