class Tab < Generator
 def generating_loop
   # stuff here which reads the tab file and returns a string and a note
 end
end

class String(starting_note)
 :attr starting_note, track
 # each String starts on a particular MIDI note, each integer in tab notation
 # represents fret numbers, both MIDI notes and fret numbers increase in half
 # steps, therefore you simply add the tab note to the start note to get the total
 # MIDI note
 def play(note)
   @track.events << NoteOnEvent.new(1, (starting_note + note), 127, 0)
   @track.events << NoteOffEvent.new(1, (starting_note + note), 0, 1000)
   # (the magic numbers are constants which would be altered in an implementation that
   # cared about rhythm and dynamics. they govern volume, note length, and MIDI
   # channel.)
 end
end

require 'midilib/sequence'
require 'midilib/consts'
include MIDI

seq = Sequence.new()

track = Track.new(seq)
seq.tracks << track
track.events << Tempo.new(Tempo.bpm_to_mpq(120))

tab = Tab.new("filename.tab")

guitar [String.new(46, track),
         String.new(52, track),
         String.new(67, track)] # these aren't the right MIDI notes
                                         # for strings to start on, but you get the idea.
                                         # also in real life the guitar would have more
                                         # than three strings

while (tab.next) do |string, note|
 string.play(note)
end
