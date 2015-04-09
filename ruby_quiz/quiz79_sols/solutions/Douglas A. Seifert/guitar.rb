require 'stringio'
begin
  require 'midilib'
rescue LoadError
  require 'rubygems' and retry
end

# *Very* simple software guitar for use with Ruby Quiz.
# See #play and the quiz for more on using this, and 
# why you might want to write your own instead.
class Guitar
  EADGBE = [40, 45, 50, 55, 59, 64]
  DADGBE = [38, 45, 50, 55, 59, 64]
  EbAbDbGbBbEb = [39, 44, 49, 54, 58, 63]   
  DGCFAD = [38, 43, 48, 53, 57, 62]

  NYLON_ACOUSTIC = 25
  STEEL_ACOUSTIC = 26
  JAZZ_ELECTRIC = 27
  CLEAN_ELECTRIC = 28
  MUTED_ELECTRIC = 29
  OVERDRIVEN_ELECTRIC = 30
  DISTORTED_ELECTRIC = 31
  HARMONICS = 32

  def Guitar.type_for_string(t)
    case t
      when 'n'
        return NYLON_ACOUSTIC
      when 's'
        return STEEL_ACOUSTIC
      when 'j'
        return JAZZ_ELECTRIC
      when 'c'
        return CLEAN_ELECTRIC
      when 'm'
        return MUTED_ELECTRIC
      when 'o'
        return OVERDRIVEN_ELECTRIC
      when 'd'
        return DISTORTED_ELECTRIC
      when 'h'
        return HARMONICS
    end

    return NYLON_ACOUSTIC
  end
 
  # Create a new guitar with the specified tuning, sounding
  # like the specified hardware guitar. You can change 
  # tempo and timing here too if you like. EADGBE is the
  # standard tuning - see the appropriate consts for 
  # some alternate tunings if you need them. 
  def initialize(instr = NYLON_ACOUSTIC, 
                 tuning = EADGBE,
                 bpm = 140,           # sounds okay with 
                 note = "eighth")     # most tabs...
    @tuning = tuning
    @seq = MIDI::Sequence.new
    @seq.tracks << (ctrack = MIDI::Track.new(@seq))
    @seq.tracks << (@track = MIDI::Track.new(@seq))
    @note = note

    @notes = { 's' => 'sixteenth', 'e' => 'eighth', 'q' => 'quarter', 'h' => 'half', 'w' => 'whole' }

    ctrack.events << MIDI::Tempo.new(MIDI::Tempo.bpm_to_mpq(bpm))
    ctrack.events << MIDI::ProgramChange.new(0,instr,0)
    ctrack.events << MIDI::ProgramChange.new(1,instr,0)
    ctrack.events << MIDI::ProgramChange.new(2,instr,0)
    ctrack.events << MIDI::ProgramChange.new(3,instr,0)
    ctrack.events << MIDI::ProgramChange.new(4,instr,0)
    ctrack.events << MIDI::ProgramChange.new(5,instr,0)

    @prev = [nil] * 6
    @prev_dist = [0] * 6
  end
 
  # Play some notes on the guitar. Pass notes in this notation:
  # 
  #   "n:6|5|4|3|2|1"
  #   first char is the note type (sixteenth, eighth, quarter, etc) followed
  #     by a colon and then the frets for each string (pipe '|' separates
  #     fret number for each string)
  #
  # Unplayed strings should be '-' or 'x'.
  #
  # So, an open Am chord could be played with:
  #
  #   axe.play("x|0|2|2|1|0")
  #
  # Which would look like this on a hardware guitar:
  #
  #   E  A  D  G  B  e
  #   ---O-----------O
  #   |  |  |  |  |  |
  #   |  |  |  |  X  |
  #   ----------------
  #   |  |  |  |  |  |
  #   |  |  X  X  |  |
  #   ----------------
  #   |  |  |  |  |  |
  #
  # for example. To play the guitar, keep calling this
  # method with your notes, and then call dump when you're
  # done to get the MIDI data.
  #   
  def play(notes)

    md = /(\w):(.+)/.match(notes)
    
    notetype = @notes[md[1]]
    d = @seq.note_to_delta(notetype)

    # n.b channel is inverse of string - chn 0 is str 6    
    md[2].split('|').each_with_index do |fret, channel|      
      if fret.to_i.to_s == fret
        fret = fret.to_i
        oldfret = @prev[channel]
        @prev[channel] = fret 

        if oldfret
          oldnote = @tuning[channel] + oldfret
          @track.events << MIDI::NoteOffEvent.new(channel,oldnote,0,d)
          d = 0
        end
        
        noteval = @tuning[channel] + fret
        @track.events << MIDI::NoteOnEvent.new(channel,noteval,80 + rand(38),d)
        d = 0
      end
    end
  end

  # dump out the notes played on this guitar to MIDI and return
  # as a string. This can be written out to a midi file, piped
  # to timidity, or whatever.
  #
  # The generated midi is simple and just uses a single track
  # with no effects or any fancy stuff.
  def dump
    out = StringIO.new
    @track.recalc_times
    @seq.write(out)
    out.string
  end
end
