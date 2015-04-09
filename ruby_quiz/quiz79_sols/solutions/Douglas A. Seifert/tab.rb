class Tab
  @@notes = [ 's', 'e', 'q', 'h', 'w']

  def initialize(debug_mode)
    @debug = debug_mode
    @tabs = Array.new
  end

  def parse(instream)
    strings = nil
    string_count = 0
    while line = instream.gets
      line.chomp!
      # ignore lines that might not be tablature lines
      if !(line =~ /^[BbGgDdAaEe\d]?[\|\) \:]?[-x<> \[\]\(\)\{\}\*\=\^\/\\~\w\.:\|\d]+$/) || line.index("-").nil?
        if ! strings.nil?
          @tabs << strings
        end
        if @debug
          puts "re does not match: #{line}"
        end
        strings = nil
        string_count = 0
        next
      end

      # Get rid of the headers
      line.sub!(/^[BbGgDdAaEe\d]?[\|\) \:]?/, "")

      # Strip off trailing garbage (nb: this doesn't strip garbage unless it is separated off from
      #  the end of the tablature line by a space... couldn't figure out how to do strip garbage in that
      #  case)
      line.sub!(/([\|\-]) .+$/, '\1')

      # Eliminate measure markers ... the way measure markers are handled is inconsistent ... most
      #  files will experience extra delay where ever there is a measure marker, but there are some tabs
      #  that don't
      line.gsub!(/[\|\:]/, "")

      # Change capital letter oh 'O' to zero '0'  ... WOW!  There are tabs that use letter O instead
      #  of number 0
      line.gsub!(/O/, "0");

      # hack until I figure out all the special notation ... this script is stupid, it just plays notes.
      # Any special notation is replaced by silence :(
      line.gsub!(/[^\d]/, "x")

      # initialize the array of guitar strings
      if strings.nil?
        strings = Array.new
      end

      # Allows appending to the guitar string line, not sure if this is necessary any more ...
      # it probably is if sets of tab lines are right next to each other with no intervening 
      # lines
      if strings[string_count].nil?
        strings[string_count] = line
      else
        strings[string_count] += line
      end

      string_count += 1
    end

    # Collect the last array of strings ...
    @tabs << strings if not strings.nil?
  end

  def play(axe, ostream)

    # For each set of tablature lines
    @tabs.each { |ss|

      if @debug
        puts "strings:\n#{ss.join("\n")}"
      end

      # Skip unless we found tablature for 6 strings
      if ss.length() != 6
        next
      end

      if @debug
        puts "PLAYING these lines!"
      end

      # Figure out how many "notes" there are ... each guitar string line is considered
      # a list of eighths, just take the string with the smallest number of eighths
      num_eighths = 1000000  
      ss.each { |str|
        if str.length < num_eighths
          num_eighths = str.length
        end
      }

      # Counter for consecutive silences
      delay_index = -1

      # What does a "silent chord" look like
      empty_chord = 'x|' * ss.size()
      i = 0
      while i < num_eighths - 1
        chord = ''
        max_number_length = 1
        # Figure out the chord ... it will be of the form 1|2|3|5|4|3|
        # two passes to handle alignment issues with two digit and one
        # digit notes... some tabs line them up on the first digit, yet
        # others line them up on the last digit.  This algorithm only
        # handles up to two consecutive digits for a note.
        ss.size().downto(1) { |s|
          this_max_number_len = 1

          # First case here is trying to deal with two digit numbers
          if ss[s-1][i].chr != "x" && ss[s-1][i+1].chr != "x"
            this_max_number_len += 1
          end
      
          # Save the size of the maximum string of numbers for later
          if this_max_number_len > max_number_length
            max_number_length = this_max_number_len
          end
        }

        # Second pass, we know the max consecutive digits, either 1 or 2
        ss.size().downto(1) { |s|
          # First case handles single digit lined up on the right
          if max_number_length > 1 && ss[s-1][i].chr == "x" && ss[s-1][i+1].chr != "x"
            chord << ss[s-1][i+1]
          # Second case handles two digit notes
          elsif ss[s-1][i].chr != "x" && ss[s-1][i+1].chr != "x"
            chord << ss[s-1][i]
            chord << ss[s-1][i+1]
          # single digit notes lined up on left
          else
            chord << ss[s-1][i]
          end
          chord << "|"
        }

        # Keep track of number of consecutive empty chords for poor man's timing
        if chord == empty_chord
          if delay_index + 1 < @@notes.length()
            delay_index += 1
          end
        else
          if delay_index == -1
            delay_index = 0
          end

          # get rid of the last pipe
          chord.chomp!("|")

          # Modified guitar wants the note in new format.  First char indicates the delay
          # that passed before current note.  After colon, we have pipe delimited note values
          # for each string
          axe.play("#{@@notes[delay_index]}:#{chord}")

          # reset the consecutive empty chords counter
          delay_index = -1
        end

        # skip past multiple digit notes
        i += max_number_length
      end

      # Not sure if this is valid, trying to put in a whole note of silence in between tabs 
      # found in the tab file.
      axe.play("w:x|x|x|x|x|x")

    }

    # Dump it to the stream
    ostream << axe.dump
  end
end
