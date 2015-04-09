# The problem can be thought of in binary.
# (Which also happens to make solving by hand easy.)
#
# i * 2 = i << 1
# i / 2 = i >> 1, only applicable if i[0] == 0
# i + 2 = i + 0b10
#
# Let's solve 22 -> 99.
# Mark the numbers in binary: 22 = 10110, 99 = 1100011
#
# Now start making the binary digits of 22 into 99's,
# progress one digit at a time:
#
# 10110
# first 1 matches but second 0 should be 1, let's add 2
# 10110 + 10 => 11000
# ok, first five match (11000, 1100011)
# shift so that we can turn the sixth into 1
# 11000 << 1 => 110000
# 110000 << 1 => 1100000
# now add two to make 6th digit match
# 1100000 + 10 => 1100010
# shift and add to make 7th digit match
# 1100010 << 1 => 11000100
# 11000100 + 10 => 11000110
# ok, all first digits match, divide to make length right
# 11000110 >> 1 => 1100011
#
# Problems appear when trying to make 255 into 257:
# 11111111 -> 100000001
#
# The shortest way is by adding 2.
# But the algorithm below fails at that and goes the long way:
# 11111111 << 1
# 111111110 + 2
# 1000000000 + 2
# 1000000010 >> 1
# 100000001
#
def nsrch(s,g)
  orig_s = s
  ss = s.to_s 2
  gs = g.to_s 2
  ops = []
  bits = gs.split(//)
  i = 0
  # Go through all bits of g.
  # If there are ones in the trailing part of ss, we
  # must get rid of them (Otherwise: 1001 -> 100, all digits match,
  # jump out of loop, make length equal by >>. Oops, it was an odd
  # number we just halved. So must check for ones.)
  while i < bits.size or ss[bits.size..-1].include? ?1
    b = bits[i]
    op = nil
    n = 0
    while ss[i,1] != b
      # Add zeroes to right to make length right and
      # to get the rightmost bit into an editable state.
      if ss.size < i+2 or s[0] == 1
        op = :*
      # Delete zeroes from right to make length right.
      elsif ss.size > i+2 and (s[0] == 0 and s[1] == 0)
        op = :/
      # Add 2 if length is ok and there are no zeroes to take out.
      # We are here because the second right-most bit is wrong.
      # Adding 2 flips it. It may also flip every bit we've just
      # went through, invalidating the invariant and thus we reset
      # the bit counter.
      else
        op = :+
        i = 0
      end
      ops << op
      s = case op
          when :+
            s + 2
          when :*
            s << 1
          when :/
            s >> 1
          end
      ss = s.to_s 2
      break if op == :+ # invariant may be bad,
                        # must check before continuing
    end
    i += 1 unless op == :+
  end
  # take out extra zeroes on right
  r = s >> (ss.size-gs.size)
  ops.push *[:/]*(ss.size-gs.size)
  # and collect middle states using done ops
  a = [orig_s]
  ops.each{|op|
    a << case op
    when :*
      a.last * 2
    when :/
      a.last / 2
    when :+
      a.last + 2
    end
  }
  a
end

if __FILE__ == $0
  p(nsrch(*ARGV.map{|n| n.to_i}))
end
