#! /usr/bin/env ruby

# This is a solution to ruby quiz 83.  The style isn't great ruby, I
# suspect, because although I've been using ruby on and off for three
# years, it's mostly been "off".  In any case, this adds the desired
# compress function to the Array class - it does so by scoring each
# possible compression of a given string and choosing the best
# possible compression.
#
# By default it uses three dots to compress text, but that can be
# changed.
#
# Compressions are scored so as to give an advantage to compressions
# that start or stop on word boundaries (handles both names_like_this
# and NamesLikeThis); also, a particular choice of how to compress a
# word is given points for preserving uncommon strings in the original
# word.
#
# The first of those (extra points for a word boundary) should be
# obvious from the score_compression routine below, but I wanted to
# mention how I encourage the shortened strings to preserve uncommon
# strings in the original word.  I do this with a function that finds
# the length of the longest common substring and then penalizes a
# compression such that it gains no benefit by preserving a string
# that occurs in every one of the inputs.
#
# Examples:
# irb(main):032:0> %w(apple grape banana orange).map{ |f|
#                     f+"_flavor" }.compress(10)
# => ["apple...", "grape...", "banana...", "orange..."]
# irb(main):033:0> %w(apple grape banana orange).map{ |f|
#                     f+"Flavor" }.compress(10)
# => ["apple...", "grape...", "banana...", "orange..."]
#
# irb(main):038:0> %w(apple grape banana orange).map { |f|
#                     [f+"_flavor",f+"_juice"]}.flatten.compress(10)
# => ["apple...or", "apple...ce", "grape...or", "grape...ce",
#     "banana...r", "banana...e", "orange...r", "orange...e"]
# irb(main):039:0> %w(apple grape banana orange).map{|f|
#                    [f+"_flavor","juice_"+f]}.flatten.compress(10)
# => ["apple...or", "ju...apple", "grape...or", "ju...grape",
#     "banana...r", "j...banana", "orange...r", "j...orange"]
#
# irb(main):042:0> ['users_controller', 'users_controller_test',
# 'account_controller', 'account_controller_test', 'bacon'].compress(10)
# => ["users...er", "use...test", "account...", "acc...test", "bacon"]

# Returns the length of the longest common
# substring of "a" and "b"
def string_similarity(a, b)
  retval = 0
  (0 ... b.length).each { |offset|
    len = 0
    (0 ... b.length - offset).each { |aind|
      if (a[aind] and b[aind+offset] == a[aind])
        len += 1
        retval = len if retval < len
      else
        len = 0
      end
    }
  }
  (1 ... a.length).each { |offset|
    len = 0
    (0 ... a.length - offset).each { |bind|
      if (b[bind] and a[bind+offset] == b[bind])
        len += 1
        retval = len if retval < len
      else
        len = 0
      end
    }
  }
  retval
end

def score_compression(target, start, len, alltargets)
  score = target.length - len
  score += 3 if len == 0
  score += 3 if (target[start,1] =~ %r(_|\W) or
                 target[start-1,2] =~ %r([a-z0-9][A-Z]))
  score += 3 if (target[start+len-1,1] =~ %r(_|\W) or
                 target[start+len-1,2] =~ %r([a-z0-9][A-Z]))
  prebit = target[0,start]
  postbit = target[start+len,target.length]
  scoreminus = 0
  alltargets.each{|s|
    scoreminus += string_similarity(s,prebit)
    scoreminus += string_similarity(s,postbit)
  }
  score - (1.0 / alltargets.length) * scoreminus
end

class Array
  def compress(n, repstr = '...')
    retval = []
    self.each { |s|
      short_specs =
      (s.length - n + repstr.length ..
       s.length - n + repstr.length + 2).inject([]) { |sp,l|
        sp + (0 .. s.length - l).map {|st| [st,l]}
      }.select { |a| a[1] > repstr.length}
      if (s.length <= n) then short_specs.unshift([0,0]) end
      retval.push(
        short_specs.inject([-999,""]) { |record, spec|
          candidate = s.dup
          candidate[spec[0],spec[1]] = repstr if spec[1] > 0
          if retval.include?(candidate)
            record
          else
            score = score_compression(s,spec[0],spec[1],self)
            if score >= record[0]
              [score, candidate]
            else
              record
            end
          end
        }[1]
      )
    }
    retval
  end
end

if __FILE__ == $0
  ARGV[1,ARGV.length].compress(ARGV[0].to_i).each {|s| puts s}
end
