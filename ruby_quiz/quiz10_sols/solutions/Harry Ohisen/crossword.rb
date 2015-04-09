
DEBUG = false

#SIZE  = 27
SIZE  = 15


class Buffer

    def initialize(string)

	@string = string
	@index  = 0
	@length = string.length

    end

    def gets

	if @index == @length
	    string = nil
	else
	    string = ""

	    while @index < @length
		c = @string[@index]

		if c == 0
		    break
		else
		    string << c

		    @index += 1
		end
	    end

	    if @index < @length
		@index += 1
	    end
	end

	return string

    end


    def read(n)

	if @index == @length
	    string = nil
	else
	    if n > (@length - @index)
		n = (@length - @index)
	    end

	    string = @string[@index, n]

	    @index += n
	end

	return string

    end

end


class Crossword


    def initialize(path, answersPath = nil)

	if path =~ /.*\.puz$/
	    ReadPUZ(path)
	elsif path =~ /.*\.txt$/
	    ReadTXT(path, answersPath)
	end

    end


    def Answer(i, j)

	if @answers
	    if @answers[i].nil?
		#$stderr.puts "@answers[#{i}] is nil !!"
		" "
	    else
		if @answers[i][j].nil?
		    #$stderr.puts "@answers[#{i}][#{j}] is nil !!"
		    " "
		else
		    if @answers[i][j] == String
			@answers[i][j]
		    else
			if (a = @answers[i][j].chr) == "."
			    " "
			else
			    a
			end
		    end
		end
	    end
	else
	    " "
	end

    end


    def CalculateNumbers

	number = 1
	size   = @grid.length

	@totalAcrossClues = 0
	@totalDownClues   = 0

	@clues = Array.new

	(0..(size - 1)).each do |i|
	    (0..(size - 1)).each do |j|
		if @grid[i][j] != -1
		    numbered = false

		    if j == 0 || (@grid[i][j - 1] == -1)
			if (j < (size - 1)) && (@grid[i][j + 1] != -1)
			    @totalAcrossClues += 1
			    @clues.push(["A", number]);

			    numbered = true
			end
		    end

		    if i == 0 || (@grid[i - 1][j] == -1)
			if (i < (size - 1)) && (@grid[i + 1][j] != -1)
			    @totalDownClues += 1
			    @clues.push(["D", number]);

			    numbered = true
			end
		    end


		    if numbered
			@grid[i][j] = number

			number += 1
		    end
		end
	    end
	end

    end


    def Clean(text)
	clean = text.gsub(/[(]/, "\\(")

	clean.gsub!(/[)]/, "\\)")
	clean.gsub!("%", "\\%")
	clean.gsub!('’', '\'')
	clean.gsub!('é', 'e')

	clean
    end


    def ReadAnswers(file)

	text = file.gets

	@answers = Array.new

	index = 0

	(0 ... SIZE).each do |i|
	    row = Array.new

	    (0 ... SIZE).each do |j|
		row[j] = text[index]

		index += 1
	    end

	    @answers.push(row)
	end

    end


    def ReadCrossword(file)

	@title = file.readline.chop

	$stderr.puts "Title is #{@title}"

	until (line = file.gets.chop) =~ /Grid/
	    # Throw this line away
	end

	@grid = Array.new

	until (line = file.gets.chop) =~ /Across/
	    if line.length > 0
		row = Array.new

		line.each_byte do |c|
		    if c.chr == 'W'
			x = 0
		    else
			x = -1
		    end

		    row.push(x)
		end

		@grid.push(row)
	    end
	end

	CalculateNumbers()

	@across = Hash.new

	while (clue = file.gets.chop) !~ /Down/

	    if clue =~ /(\d*) (.*)/
		number = $1
		text   = $2

		@across[number] = text
	    end

	end

	@down = Hash.new

	while !file.eof
	    clue = file.gets.chop

	    if clue =~ /(\d*) (.*)/
		number = $1
		text   = $2

		@down[number] = text
	    end
	end
    end


    def ReadPUZ(path)

	File.open(path, "rb") do |file|
	    #file.binmode

	    data = file.sysread(file.stat.size)

	    buffer = Buffer.new(data)

	    # Skip header information ...

	    buffer.read(52)

	    # Pull out the various strings we need ...

	    @answersString = buffer.read(SIZE * SIZE)
	    @gridString	   = buffer.read(SIZE * SIZE)
	    @title	   = buffer.gets
	    @creator	   = buffer.gets.strip

#$stderr.puts "@answersString = '#{@answersString}'"

#$stderr.puts "title   = >>#{@title}<<"
#$stderr.puts "creator = >>#{@creator}<<"

	    @title << "  \(#{@creator}\)"

	    # Skip over a string we don't need ...

	    @extra	   = buffer.gets

	    # Read the clue strings ...

	    @clueStrings = Array.new

	    while (s = buffer.gets) != nil
		@clueStrings.push(s)
	    end

	    @grid = Array.new

	    index = 0

	    (0 ... SIZE).each do |i|
		row = Array.new

		(0 ... SIZE).each do |j|
		    c = @gridString[index].chr

		    if c == "."
			row.push(-1)
		    else
			row.push(0)
		    end

		    index += 1
		end

		@grid.push(row)
	    end

	    CalculateNumbers()

	    @answers = Array.new

	    index = 0

	    (0 ... SIZE).each do |i|
		row = Array.new

		(0 ... SIZE).each do |j|
		    row[j] = @answersString[index]


		    if row[j].nil?
			row[j] = ' '
		    end

#$stderr.puts "@answers[#{i}][#{j}] = #{row[j].chr}"

		    index += 1
		end

		@answers.push(row)
	    end

	    index   = 0

	    @across = Hash.new
	    @down   = Hash.new

	    @clues.each_index do |i|
		clue   = @clues[i]
		type   = clue[0]
		number = clue[1]
		string = @clueStrings[i]

		if type == "A"
		    @across[number] = string
		else
		    @down[number] = string
		end
	    end
	end

    end


    def ReadTXT(path, answersPath)

	File.open(path) do |file|

	    ReadCrossword(file)

	end

	if answersPath == nil
	    @answers = nil
	else
	    File.open(answersPath) do |file|

		ReadAnswers(file)

	    end
	end

    end


    def each_grid
	rowNumber = 0

	@grid.each do |row|
	    rowNumber += 1

	    columnNumber = 0

	    row.each do |column|
		columnNumber += 1

		yield rowNumber, columnNumber, column
	    end
	end
    end


    def each_across
	(@across.keys.sort { |a, b| a.to_i <=> b.to_i }).each do |number|
	    yield number, @across[number]
	end
    end


    def each_down
	(@down.keys.sort { |a, b| a.to_i <=> b.to_i }).each do |number|
	    yield number, @down[number]
	end
    end


    def Output
	puts "#{@title}\n\n"

	puts "Grid"

	@grid.each do |row|
	    row.each do |column|
		x = (column == -1) ? "B" : "W"
		print "#{x}"
	    end

	    puts ""
	end

	puts "\nAcross\n\n"

	(@across.keys.sort { |a, b| a.to_i <=> b.to_i }).each do |number|
	    printf "%02d %s\n", number, @across[number]
	end

	puts "\nDown\n\n"

	(@down.keys.sort { |a, b| a.to_i <=> b.to_i }).each do |number|
	    printf "%02d %s\n", number, @down[number]
	end
    end


    def OutputAcross

	puts "AcrossHeader"
	puts "StartAcrossClues"

	self.each_across do |number, text|
	    puts "#{number} StartClue"

	    clean = Clean(text)
	    words = clean.split(" ")

	    words.each do |w|
		puts "(#{w}) ClueWord"
	    end
	end

    end


    def OutputDown
	puts "DownHeader"
	puts "StartDownClues"

	self.each_down do |number, text|
	    puts "#{number} StartClue"

	    clean = Clean(text)
	    words = clean.split(" ")

	    words.each do |w|
		puts "(#{w}) ClueWord"
	    end
	end

    end


    def OutputGrid(withAnswers)

	size = @grid.length

	(0..(size - 1)).each do |i|
	    (0..(size - 1)).each do |j|
		x = @grid[i][j]

		if x == -1
		    puts "#{j} #{i} BlackSquare"
		else
		    if withAnswers
			a = Answer(i, j)

#$stderr.puts "Answer(#{i}, #{j}) = #{a}"

			puts "#{j} #{i} #{x} (#{a}) WhiteSquare"
		    else
			puts "#{j} #{i} #{x} ( ) WhiteSquare"
		    end
		end
	    end
	end

    end


    def OutputNewPage
	puts "\nshowpage\n"
    end

    def OutputPostscript(withAnswers)
	OutputPreamble()
	OutputSubroutines()
	OutputGrid(withAnswers)
	OutputTitle()

	if SIZE > 15
	    OutputNewPage()
	end

	OutputAcross()
	OutputDown()
	OutputPrologue()
    end


    def OutputPreamble(out = $stdout)

	# Output the necessary Postscript preamble, via
	# a here document ...

	out.puts <<PREAMBLE
%!PS-Adobe-3.0
%%Creator: Harry O's Crossword Printer
%%LanguageLevel: 2
%%DocumentMedia: plain 612 792 0 () ()
%%Pages: 1
%%EndComments
%%BeginDefaults
%%PageMedia: plain
%%EndDefaults
%%BeginProlog
%%EndProlog

PREAMBLE

    end


    def OutputPrologue(out = $stdout)

	out.puts "\n\nshowpage"

    end


    def OutputSubroutines(out = $stdout)

	# Output the necessary Postscript subroutines via
	# a here document ...

	out.puts <<SUBROUTINES

%
% Set the fonts to use ...
%

/NUMBERFONT /TimesRoman findfont 6  scalefont def
/ANSWERFONT /TimesRoman findfont 12 scalefont def


%
% Grid size ...
%

/GRID_SIZE #{SIZE} def


%
% Size of square ...
%

/SQUARE_SIZE 22 def


%
% Define the top lefthand corner of the
% crossword grid ...
%

/GRID_TOPX 8.5  72 mul GRID_SIZE SQUARE_SIZE 1 add mul sub 2 div def
/GRID_TOPY 11.5 72 mul def

/CLUE_TOPX GRID_TOPX 0 add def

/CLUE_TOPY #{(SIZE == 15) ? "GRID_TOPY SQUARE_SIZE GRID_SIZE mul sub 5 sub" : "GRID_TOPY 70 sub"} def


%
% How high each line of clue text is ...
%

/CLUE_HEIGHT 10 def


%
% Define the width of the space we have for
% a column of clue text ...
%

/CLUE_WIDTH GRID_SIZE SQUARE_SIZE 1 add mul 2 div 25 sub def


%
% The space from the start of the clue lines
% to the clue text ...
%

/CLUE_SPACING 15 def


%
% How to output the across header ...
%

/AcrossHeader
{
    CLUE_TOPX CLUE_TOPY moveto

    /TimesRomanBold findfont 12 scalefont setfont

    (Across) show
}
def


%
% How to draw a black square
%

/BlackSquare
{
    % Store the stack contents: X Y

    SQUARE_SIZE 1 sub mul GRID_TOPY exch sub /topY exch def
    SQUARE_SIZE 1 sub mul GRID_TOPX exch add /topX exch def

    % Start a new path to be stroked out ...

    newpath

    % Move to the top-left corner and draw a square,
    % using relative lineto's ...

    topX                	topY            	moveto
    SQUARE_SIZE 1 sub     	0               	rlineto
    0                   	SQUARE_SIZE 1 sub neg	rlineto
    SQUARE_SIZE 1 sub neg	0           		rlineto
    closepath

    fill
}
def


%
% Add a word to the current clue ...
%

/ClueWord
{
    /WORD exch def

    % Calculate the width of this word, plus a couple
    % of pixels for spacing ...

    /WORD_WIDTH WORD stringwidth pop 2 add def
    
    % Work out whether there's enough space left on the
    % current line for this word ...

    WORD_WIDTH CLUE_X add CLUE_LEFTX sub
    CLUE_WIDTH gt
    {
	% This word won't fit, so move to the
	% next line ...

	/CLUE_Y CLUE_Y CLUE_HEIGHT sub def
	/CLUE_X CLUE_LEFTX CLUE_SPACING add def
    }
    if

    CLUE_X CLUE_Y moveto WORD show

    /CLUE_X CLUE_X WORD_WIDTH add def
}
def


%
% How to output the down header ...
%

/DownHeader
{
    CLUE_TOPX SQUARE_SIZE  GRID_SIZE mul 2 div add
    CLUE_TOPY
    moveto

    /TimesRomanBold findfont 12 scalefont setfont

    (Down) show
}
def


%
% Start a new clue ...
%

/NewClue
{
    /NUMBER exch def
}
def


%
% Draw a number, in the specified width ...
%

/Number
{
    2 string cvs show
}
def


%
% Start a new clue ...
%

/StartClue
{
    % Pull the clue number off the stack ...

    /NUMBER exch def

    % Set the X coordinate to the current
    % left margin ...

    /CLUE_X CLUE_LEFTX def

    % Move down a line ...

    /CLUE_Y CLUE_Y CLUE_HEIGHT sub 2 sub def

    % Move to the appropriate (X, Y) ...

    CLUE_X CLUE_Y moveto

    % Output the clue number in Time Roman Bold 10 pt ...

    /TimesRomanBold findfont 10 scalefont setfont

    NUMBER 2 string cvs show

    % Start the clue text a few pixels to the
    % right of the clue number column ...

    /CLUE_X CLUE_X CLUE_SPACING add def

    % Make sure the clue text comes out in the right
    % font ...

    /TimesRoman findfont 10 scalefont setfont
}
def


%
% Start the across clues ...
%

/StartAcrossClues
{
    CLUE_TOPX StartClueList
}
def


%
% Set the offset for the start of clues ...
%

/StartClueList
{
    /CLUE_LEFTX exch def

    CLUE_TOPY /CLUE_Y exch def
}
def


%
% Start the down clues ...
%

/StartDownClues
{
    CLUE_TOPX SQUARE_SIZE GRID_SIZE mul 2 div add StartClueList
}
def


%
% Draw the crossword's title ...
%

/Title
{
    % Store the title ...

    /TITLE exch def

    % Calculate the X offset required to centre
    % the title above the crossword ...

    /TimesRomanBold findfont 14 scalefont setfont

    SQUARE_SIZE 1 sub GRID_SIZE mul
    TITLE stringwidth pop sub
    2 div
    GRID_TOPX add

    GRID_TOPY 12 add

    moveto

    TITLE show
}
def


%
% How to draw a white square
%

/WhiteSquare
{
    % Store the stack contents: X Y NUMBER ANSWER

    /ANSWER exch def
    /NUMBER exch def

    SQUARE_SIZE 1 sub mul GRID_TOPY exch sub /topY exch def
    SQUARE_SIZE 1 sub mul GRID_TOPX exch add /topX exch def

    % Start a new path to be stroked out ...

    newpath

    % Move to the top-left corner and draw a square,
    % using relative lineto's ...

    topX                	topY            	moveto
    SQUARE_SIZE 1 sub     	0               	rlineto
    0                   	SQUARE_SIZE 1 sub neg	rlineto
    SQUARE_SIZE 1 sub neg	0           		rlineto
    closepath

    stroke

    % Add the clue number ...

    NUMBER 0 gt
    {
	NUMBERFONT setfont

	topX 2 add topY 6 sub moveto NUMBER 2 string cvs show
    }
    if

    % Add the answer (which may be blank) ...

    ANSWERFONT setfont

    topX 7 add topY 16 sub moveto ANSWER show
}
def


% Set the line width to one pixel and colour to black ...

1 setlinewidth
0 setcolor

0.80 0.80 scale
120 45 translate

SUBROUTINES

    end


    def OutputTitle(out = $stdout)

	out.puts "(#{@title}) Title"

    end


    def Title
	@title
    end
    
end


if $0 == __FILE__

    crosswordFile = ARGV[0]

    if ARGV.length > 1
	answers = ARGV[1]
    else
	answers = nil
    end
	
    c = Crossword.new(crosswordFile, answers)

    c.OutputPostscript(answers != nil)

end

