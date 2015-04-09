module NumericMazeSolver

  module BitHelpers

    def bit_len(num)
      return num.to_s(2).length
    end

  end

  class NumericPath
    attr_reader :result, :ops

    def initialize(s)
      @result = [s]
      @ops = ''
    end

    def reset(s = nil)
      @result.slice!(1, @result.length)
      @result[0] = s if s
      @ops = ''
    end

    def cur
      @result.last
    end

    def src
      @result.first
    end

    def add_two
      @result << (cur + 2)
      @ops << 'a'
      #p @result
    end

    def double
      @result << (cur << 1)
      @ops << 'd'
      #p @result
    end

    def halve
      c = cur
      fail "Trying to halve an odd number: #{c}" unless (c % 2) == 0
      c >>= 1
      @result << c
      @ops << 'h'
      #p @result
    end

    def add_one
      double
      add_two
      halve
    end

  end

  class Solver
    include BitHelpers

    def validate(src, dst)
      fail "We only deal with integers." unless
        (dst.kind_of? Integer) && (src.kind_of? Integer)
      fail "Not dealing with negative numbers" if
        (dst<0) || (src<0)
      fail "Can't get to zero from a positive number." if
        (dst==0) && (src>0)
    end

    def initialize(src, dst)
      validate(src, dst)
      @dst = dst
      @dst_bit_len = bit_len(@dst)
      @result = NumericPath.new(src)
    end

    def shifted_diff
      tmpsrc = @result.cur
      tmpdst = @dst
      src_bit_len = bit_len(tmpsrc)
      shift = src_bit_len - @dst_bit_len
      if shift < 0
        tmpsrc >>= shift #really a left shift, since shift is negative
      else
        tmpdst <<= shift
      end
      xor_not_sub = tmpdst < tmpsrc
      diff = xor_not_sub ? (tmpdst ^ tmpsrc) : (tmpdst - tmpsrc)
      top_matched = bit_len(tmpdst) - bit_len(diff)
      return [ diff, shift, top_matched, src_bit_len ]
    end

    def solve
      @result.reset
      while @result.cur != @dst
        diff, shift, top_matched, src_bit_len = shifted_diff
        dist_from_top = src_bit_len - top_matched
#       p @result.result
#       puts "src  = #{@result.cur.to_s(2)}"
#       puts "dst  = #{@dst.to_s(2)}"
#       puts "diff = #{diff.to_s(2)}\n"
#       puts "dist = #{dist_from_top}\n"
        if diff==0
          while shift > 0
            @result.halve
            shift -= 1
          end
          while shift < 0
            @result.double
            shift += 1
          end
        elsif dist_from_top > 5
          # getting there
          try_to_halve(@result.cur)
        elsif dist_from_top == 5
          # one away!
          # do this now in case we'd have to double-add-halve
          # unnecessarily later
          bit = 1 << (2 + shift + top_matched)
          if (diff&bit) != 0
            @result.add_two
          end
          @result.halve
        elsif dist_from_top == 4
          if shift > 0
            try_to_halve(@result.cur)
          else
            4.times { @result.add_two }
          end
        elsif dist_from_top == 3
          if shift > 0
            try_to_halve(@result.cur)
          else
            2.times { @result.add_two }
          end
        elsif dist_from_top == 2
          @result.add_two
        else
          @result.double
        end
      end
      return [ @result.result, @result.ops ]
    end

    private

    def try_to_halve(cur)
      if ((cur&1) != 0)
        # odd, so we can't halve yet
        @result.double
        @result.add_two
      elsif ((cur&2) != 0)
        # won't be able to halve again
        @result.add_two
      else
        @result.halve
      end
    end

  end

end
