#!/bin/env ruby

## Quiz 153 Solution
## Print max repeated non-overlaping substring from STDIN or nothing.
## Not suffix tree! Less memory! Very fast!
## Enjoy,
## Sergey

##
# Usage: Q153_SerVo.rb {-U | [-t] [-n]}
# -U - run unit test
# Otherwise:
# reads standard input,
# replaces linebreak with space inside paragraph if -t,
# prints longest repeated substring / its length only if -n

class String
    def longest_repeated_substring
        # repeated substring length
        clen = 1
        # repeated substring posistion
        cpos = 0
        # result
        rs = nil
        # two substrings after cpos
        while cpos+clen*2 <= self.size
            # second repeated substring posistion
            unless ipos = self.index( self.slice(cpos,clen), cpos+clen )
                # try next position, same length
                cpos+=1
                next
            end
            # extend repeated substring
            begin
                clen += 1 while cpos+clen<ipos &&
                                (c = self[ipos+clen]) &&
                                c == self[cpos+clen]
            end while ipos=self.index(self.slice(cpos,clen), ipos+clen)
            # save repeated string
            rs = self.slice(cpos,clen)
            # try longer substring
            clen += 1
            # find next position of repeated substring of length clen
            ncpos = nil
            ht = Hash.new
            # search for repeated substring
            for i in cpos..self.size-clen
                # current substring
                cs=self.slice(i,clen)
                # seen this substring before?
                if prev_pos=ht[cs]
                    # check overlap
                    next if prev_pos+clen>i
                    # repeated substring found
                    ncpos = prev_pos
                    break
                end
                # store substring
                ht[cs]=i
            end
            break unless ncpos
            cpos=ncpos
        end
        rs
    end
end

if __FILE__ == $0
    if ARGV.first == '-U'
        ARGV.shift
        require 'test/unit'
        class TC_LRS < Test::Unit::TestCase
            def test_lrs
                assert_same  nil, ''.longest_repeated_substring

                d='1234567890'
                dx = (1..9).inject(d){|r,i|r+'.'+r[0,i]}+'.'+d
#1234567890.1.12.123.1234.12345.123456.1234567.12345678.123456789.1234567890

                assert_same  nil, d.longest_repeated_substring
                assert_equal d, (d+d).longest_repeated_substring
                assert_equal d, (d+'.'+d).longest_repeated_substring
                assert_equal d, dx.longest_repeated_substring

                a=d.gsub( /\d/, 'A' )
                ax = dx.gsub( /\d/, 'A' )
#AAAAAAAAAA.A.AA.AAA.AAAA.AAAAA.AAAAAA.AAAAAAA.AAAAAAAA.AAAAAAAAA.AAAAAAAAAA

                assert_equal a, (a+a).longest_repeated_substring
                assert_equal a, (a+'.'+a).longest_repeated_substring
                assert_not_equal a, ax.longest_repeated_substring
            end
        end
        p :TEST
        exit Test::Unit::AutoRunner.run
    end

    ###
    # Main
    inp = STDIN.read
    # for 'human text' processing (-t):
    # replace '\n' inside paragraph with ' '
    inp.gsub!(/(\S)\n(\w)/m, '\1 \2') if ARGV.grep( /-.*t/ )[0]

    if lrs = inp.longest_repeated_substring
        # Output string unless '-n' specified (number only)
        puts( lrs ) if ARGV.grep( /-.*n/ ).empty?
        # Output size
        p [lrs.size]
    end
end
