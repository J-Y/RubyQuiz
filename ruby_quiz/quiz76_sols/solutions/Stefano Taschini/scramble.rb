#!/usr/bin/env ruby

require 'unicode'

class String

  Diacritic = Regexp.new("[\xcc\x80-\xcd\xaf]",nil,'u')
  Specials = "\xc3\x86\xc3\x90\xc3\x98\xc3\x9e\xc3\x9f\xc3\xa6\xc3\xb0\xc3\xb8\xc3\xbe"
  Letter = Regexp.new("[A-Za-z#{Specials}](?:#{Diacritic}*)",nil,'u')
  Word = Regexp.new("(#{Letter})(#{Letter}+)(?=#{Letter})",nil,'u')

  def scramble
    Unicode.compose(Unicode.decompose(self).gsub(Word) {
      m = $~
      m[1] + m[2].scan(Letter).sort_by{rand}.join})
  end

end

if __FILE__ == $0
  while gets
    puts $_.chomp.scramble
  end
end
