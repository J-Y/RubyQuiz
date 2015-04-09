#!/bin/ruby -w
#
## Sergey Volkov
## Ruby Quiz #76 - Text Munger (by Matthew Moss)
## Thanks Matthew - it was fun!
#
=begin
On Apr 21, 2006, at 12:26 PM, Sergey Volkov wrote:
> May I suggest smthng to make it more challenging?
> 1. Vowel can be exchanged with vowel only,
>    consonant can be exchanged with consonant only;
> 2. Parameterize the solution, so that set of exchangeable
> characters classes
>    can be specified (optionally);

On Apr 21, 2006, at 1:34 PM, James Edward Gray II replied:
>..
> The Ruby Quizzes are ideas.  If you need to add this to challenge
> yourself, go for it.  We won't come and take your keyboard away, I
> promise.  ;)

Thanks James, your promise is very encouraging!
=end

class String
    # intermix characters matching rx (default /./)
    def intermix! rx=/./
        pos, pp = -1, []
        # process every matching char index
        while pos = self.index( rx, pos+1 )
            if pp[0]
                # select randomly previously saved pos
                rp = pp[rand(pp.size)]
                # swap
                self[pos], self[rp] = self[rp], self[pos]
            end
            # save current pos
            pp << pos
        end
        # return modified string
        self
    end
end

# character classes
# change them for localization (I didn't tested)
VOWEL     = /[aeyuio]/i
CONSONANT = /[#{('b'..'z').to_a.join.gsub!(VOWEL, '')}]/i
WORDCHAR  = /[#{('a'..'z').to_a.join}]/i

# specify -d to process text from the end of this file
text = (ARGV[0]=='-d' ? DATA : ARGF).read
print text.gsub!( /#{WORDCHAR}{3,}'?/ ){ |word|
    epos = word.size - (word[-1]==?\' ? 1 : 2)
    # I was lazy to implement command line option for mix mode..
    # mix VOWELs
    word[1..epos]=word[1..epos].intermix!(VOWEL)
    # mix CONSONANTs
#    word[1..epos]=word[1..epos].intermix!(CONSONANT)
    # we can mix all letters
    #word[1..epos]=word[1..epos].intermix!(WORDCHAR)
    word
} || text

__END__
Execute 'SV.rb -d' and compare output with_the_text below.
If you can understand easyly, try to uncomment line 59 :)

Assumptions:
    processing words as sequence of characters matching
    regular expression in WORDCHAR constant possibly terminated
    with apostrophe (single quote)
Constraints:
    consonant-consonant, vowel-vowel exchange only, that's my challenge;
    localization is out of scope, that's my decision;

Enough testing phrases, better have pure fun playing with:
$ fortune | ruby SV.rb
Dametitconoun is like sex: when it is good, it is very, very good; and
when it is bad, it is better than nintohg.
                -- Dick Bdornan
