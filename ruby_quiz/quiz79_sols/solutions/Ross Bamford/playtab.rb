#!/usr/local/bin/ruby
#
# This is a very simple solution to this quiz, using
# the simple software guitar supplied. Run e.g:
#
#   ./playtab.rb sometab.tab | timidity -Os -
#
# Using the correct -O (s is ALSA - see --help for more).
# Alternatively, file the output and load it in your
# midi player.
#
require 'guitar'

tabre = /(([eADGBE]\|?
         [\-0-9~xhpbrBend\(\)\[\]\{\}=*|#]+
         [.\r\n]*){6})/x
tabs = []

ARGF.read.scan(tabre) {
  tab = $1.split
  tabs << tab if tab.all? { |line| line.length == tab[0].length }
}

axe = Guitar.new(Guitar::CLEAN_ELECTRIC)
tabs.inject([[]]) do |bars,t|
  (t[0].length - 2).times do |i|
    notes = t.inject("") { |s,line| s << line[i+2] }.reverse
    if notes =~ /[|*]{6}/
      bars << []
    else
      bars.last << notes
    end
  end
  bars
end.reject { |a| a.empty? }.each do |bar|
  bar.each do |notes|
    axe.play(notes)
  end
end

$stdout.write(axe.dump)
