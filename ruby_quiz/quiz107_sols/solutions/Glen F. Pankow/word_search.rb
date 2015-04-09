#! /usr/bin/env ruby
#
#  quiz-107  --  Ruby Quiz #107.
#
#  See the Ruby Quiz #107 documentation for more information
#  (http://www.rubyquiz.com/quiz107.html).
#
#  I do the basic quiz, although with no extra credit work.
#
#  Glen Pankow      12/29/06
#
#  Licensed under the Ruby License.
#
#----------------------------------------------------------------------------
#
#  When thinking about this quiz, I didn't want to take the usual matrix-type
#  approach, but instead to do simple string matches against interesting or
#  clever transformations of the quiz text lines.  I thought this would be
#  quite easy, but soon found a way to use more interesting transformations
#  that proved a bit trickier.  Not that this turned out amenable for the quiz
#  extra credit problems, but what the hey.
#


class String

    #
    # upcase_trim
    #
    # Return a copy of the current string with a non-letter characters trimmed
    # and all lower case letters converted to upper case.
    #
    def upcase_trim
        upcase.gsub(/[^A-Z]/, '')
    end


    #
    # replicate_match(strs, replication_str)
    #
    # If any of the simple Strings in the Array <strs> is found in the current
    # string (possibly in multiple places and possibly overlapping), the String
    # <replication_str> is updated with the matching string in the corresponding
    # location.  <strs> may also be a single String object.
    #
    # For example, 'abdcbcbcb'.replicate_match(['cbc', 'ab'], '---------')
    # updates the '---------' to 'ab-cbcbc-'.
    #
    def replicate_match(strs, replication_str)
        strs = [ strs ] unless (strs.is_a?(Array))
        strs.each do |str|
            str_len = str.length
            next if (length < str_len)
            offset, last_offset = 0, length - str_len
            while (offset <= last_offset)
                if str_pos = index(str, offset)
                    replication_str[str_pos, str_len] = str
                    offset = str_pos
                end
                offset += 1
            end
        end
    end


    #
    # spacey_str = string.space_out
    #
    # Return a copy of the current string with space characters inserted
    # between its characters (plus an initial space character).
    #
    def space_out
        gsub(/(.)/, ' \1')
    end
end



class WordSearch

    #
    # word_search = WordSearch.new
    #
    # Initialize and return an empty word search puzzle object.
    #
    def initialize
        @text_lines = [ ]
    end


    #
    # word_search.add_line(line)
    #
    # Add the String <line> to the current word search puzzle object.
    #
    def add_line(line)
        @text_lines << line.upcase_trim
    end


    #
    # word_search.solve(*words)
    #
    # Solve the current word search object for the words <words>.  The solution
    # is returned, which is an Array of Strings in the same shape as the
    # original puzzle, where the solution word letters are kept intact, but the
    # non-solution word letters replaced with the character '+'.
    #
    # We tackle this problem by doing simple string matches of <words> over
    # repeated transformations of the puzzle text lines:
    #
    #    ABCD hflip  DCBA diag  D  hflip  D  undiag  DHL
    #    EFGH -----> HGFE ----> CH -----> HC ------> CGK
    #    IJKL        LKJI       BGL       LGB        BFJ
    #    (L->R)      (R->L)     AFK       KFA        AEI
    #     ^                     EJ        JE         (T->B)
    #     |                     I         I           |
    #     | undiag              (TL->BR)  (BR->TL)    | hflip
    #     |                                           v
    #    A   hflip  A   diag  AEI  hflip  IEA  vflip LHD
    #    BE <------ EB <----- BFJ <-----  JFB <----- KGC
    #    CFI        IFC       CGK         KGC        JFB
    #    DGJ        JGD       DHL         LHD        IEA
    #    HK         KH                               (B->T)
    #    L          L
    #    (TR->BL)  (BL->TR)
    #
    # Other types of transformations (such as straight transpose) would be
    # easier (by simply undoing some transformation steps), but would require
    # more steps.
    #
    def solve(*words)
        words = words.collect { |word| word.upcase_trim }

        #
        # Make the various transformations, checking for matches along the
        # way.
        #
        normalize            ;  replicate_match(words)      # match L->R
        flip_horizontal      ;  replicate_match(words)      # match R->L
        diagonalize          ;  replicate_match(words)      # match TL->BR
        flip_horizontal      ;  replicate_match(words)      # match BR->TL
        undiagonalize(true)  ;  replicate_match(words)      # match T->B
        flip_horizontal      ;  replicate_match(words)      # match B->T
        flip_vertical ; flip_horizontal
        diagonalize          ;  replicate_match(words)      # match BL->TR
        flip_horizontal      ;  replicate_match(words)      # match TR->BL
        undiagonalize(false)

        #
        # And return the solution.
        #
        @sltn_lines
    end

protected

    #
    # word_search.normalize
    #
    # Undiagonalizing is somewhat tricky, as we need to recover its original
    # (or transposed) shape.  Set the internal state of this object for
    # suitable shape information.
    #
    # Also, (un)diagonalizing will be screwed up if this shape is not a nice,
    # full rectangle.  Pad it if necessary.  And, clear out the solution array
    # (and give it the same shape).
    #
    def normalize
        @height = @text_lines.size
        @width = 0
        @sltn_lines = [ ]
        @text_lines.each do |line|
            len = line.length
            @width = len if (len > @width)
            @sltn_lines << '+' * len
        end
        (0...@text_lines.size).each do |i|
            no_pad_chars = @width - @text_lines[i].length
            1.upto(no_pad_chars) do
                @text_lines[i] << '+'
                @sltn_lines[i] << '+'
            end
        end
    end


    #
    # word_search.flip_horizontal()
    #
    # Flip all the lines of the current word search puzzle object horizontally.
    #
    # (Note:  this and all similar methods should more appropriately be named
    # in their bang (!) forms, but I don't do that for this quiz, nor do I do
    # other normal things here like returning self.)
    #
    def flip_horizontal
        (0...@text_lines.size).each do |i|
            @text_lines[i].reverse!
            @sltn_lines[i].reverse!
        end
    end


    #
    # word_search.flip_vertical()
    #
    # Flip all the lines of the current word search puzzle object vertically.
    #
    def flip_vertical
        @text_lines.reverse!
        @sltn_lines.reverse!
    end


    #
    # word_search.diagonalize()
    #
    # Convert the lines of the current word search puzzle object to a kind of
    # diagonalized form.
    #
    # Note that here I don't presize the arrays, and so use the ||= trick
    # (well, I suppose it's possible to figure out how big to make the arrays,
    # but I didn't bother doing that).
    #
    def diagonalize
        text_lines = @text_lines  ;  @text_lines = [ ]
        sltn_lines = @sltn_lines  ;  @sltn_lines = [ ]
        text_lines.each_with_index do |line, i|
            line.split('').each_with_index do |char, j|
                (@text_lines[i+j] ||= '') << char
                (@sltn_lines[i+j] ||= '') << sltn_lines[i][j]
            end
        end
    end


    #
    # word_search.undiagonalize(transposed)
    #
    # Convert the lines of the current word search puzzle object back into a
    # rectangular form.  Because we don't do true matrix-like manipulation (we
    # work with simple strings) and thus lose any original indexing (via simple
    # string appending), we need original shape information in order to do the
    # reconstruction.
    #
    # But this is perhaps fortuitous, because we can in fact reconstruct the
    # lines into a transposed-like shape (saving us several transformation
    # steps).
    #
    def undiagonalize(transposed)
        text_lines = @text_lines
        @text_lines = Array.new(transposed ? @width : @height) { String.new }
        sltn_lines = @sltn_lines
        @sltn_lines = Array.new(transposed ? @width : @height) { String.new }
        text_lines.each_with_index do |line, i|
            if (transposed)
                o = (i + 1 < @height)? 0 : i + 1 - @height
            else
                o = (i + 1 < @width)? 0 : i + 1 - @width
            end
            line.split('').each_with_index do |char, j|
                @text_lines[j+o] << char
                @sltn_lines[j+o] << sltn_lines[i][j]
            end
        end
    end


    #
    # word_search.replicate_match(words)
    #
    # Update the solution lines of the current word search puzzle object with
    # any matches of the word Strings <words>.
    #
    def replicate_match(words)
        @text_lines.each_with_index do |line, i|
            line.replicate_match(words, @sltn_lines[i])
        end
    end
end


#
# Go for it!
#
puzzle = WordSearch.new
infile = ((ARGV.size == 0) || (ARGV[0] == '-'))? $stdin : File.open(ARGV[0])
loop do
    line = infile.gets
    break if line =~ /^\s*$/
    puzzle.add_line(line)
end
words = infile.gets.strip.split(/\s+/)
print "\nAnd the solution is:\n  ",
  puzzle.solve(*words).collect { |line| line.space_out }.join("\n  "), "\n"
