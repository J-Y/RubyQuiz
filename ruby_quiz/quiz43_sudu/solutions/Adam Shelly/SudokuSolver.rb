#!/usr/bin/env ruby

# SodukuSolver.rb
# author: Adam Shelly
# Solves soduku puzzles.
# supports arbitrary grid sizes (tested upto 16x16)

def dprint(s)
    print s if $DEBUG
end

class BadGuessException < Exception
end

    #Utility function to define the box dimensions inside a grid
    @@boxcols = 0    
    def GetBoxBounds(gridsize)
        if (@@boxcols > 0)
            [gridsize/@@boxcols, @@boxcols]
        else
            case gridsize
                when 1 then [1,1]
                when 2 then [1,2]
                when 4 then [2,2]
                when 6 then [2,3]
                when 8 then [2,4]
                when 9 then [3,3]
                when 10 then [2,5]
                when 12 then [3,4]
                when 14 then [2,7]
                when 15 then [3,5]
                when 16 then [4,4]
                else 
                    print "GridSize of #{gridsize} unsupported. Exiting\n"
                    [0,0]            
                end
        end
    end

# a Cell represents a square on the grid.
#  it keeps track of all possible values it could have.
#  it knows its grid location for convenience
class Cell 
    attr_reader :row, :col, :box, :possible
    def initialize(row, col, val=-1, max = 9)
        @row = row
        @col = col
        bounds = GetBoxBounds(max)
        @box = (col/(bounds[0])+((row/bounds[1])*bounds[1])+max/2)%max
        @processed = false
        if (val.is_a?(Array))
                @possible = val.dup 
                #if you don't dup here, you get big trouble
                 # when undoing guesses
        elsif ((1..max) === val)
            @possible = [val]
        else
            @possible = (1..max).to_a
        end
    end

    def includes?(n)
        @possible.include?(n)
    end

    def mark
        @processed = true
    end

    def set(toValue)
        @possible = [toValue] if found = @possible.include?(toValue)
        found
    end

    def hasFinalValue
        return @possible[0] if (@possible.length == 1)
    end

    def eliminate(n)
        raise BadGuessException if (@possible.length == 0) 
        @possible.delete(n)
        hasFinalValue && !@processed
    end

    def override(a)
        @possible = a.dup
        @processed = false
    end

    def to_s
        if $DEBUG
            s = @possible.to_s;
            s.length.upto(9) do s << " " end
            "["+s+"]"
        else
            (v = hasFinalValue)?" "+v.to_s(32):" _"
        end
    end
    def >(other)
        return (@row > other.row || (@row == other.row && @col > other.col))
    end
end 

class Guess
    def initialize(cell )
        @row,@col = cell.row,cell.col
        @store = cell.possible.clone
        @index = 0
    end
    def value
        @store[@index]
    end
    def remove(cellset)
        cell=cellset[@row][@col]
        cell.eliminate(value)
        cell
    end
    def to_s
        "Guess [#{@row},#{@col}] to be #{@store[@index]} from [#{@store}] "
    end
end


class Solver
    def initialize(boardlist, size, presolved = false, lev=0)
        @level = lev+1
        @size = size
        become(boardlist, presolved)
    end
    #helper for init and cloning
    def become(boardlist, presolved = true)
        @boxes =[]
        @rows =[]
        @cols = []    
        @queue = [] #a list of cells to check for solutions.
        @size.times{ |n|  @boxes[n] = [] ; @rows[n]=[]; @cols[n]=[]    }
        r=c=0
        boardlist.each do |v|
            cell = Cell.new(r,c,v, @size)
            @boxes[cell.box] <<@rows[r][c] = @cols[c][r] = cell
            @queue << cell
            cell.mark if (presolved && cell.hasFinalValue)
            c+=1
            if (c==@size) then c=0;    r=r+=1 end
        end
    end

    def unsolved
        @size.times do |n|
            @boxes[n].each {|c| return c if !c.hasFinalValue}
        end
        nil
    end

    def solve
        while @queue.size > 0
            while (cell = @queue.pop)
                eliminateChoices(cell) 
            end
            checkForKnownValues()
        end
        dprint "Solved to...\n#{self}"
        return unsolved ? startGuessing  : true
    end

    #for any resolved cell, eliminate its value from the possible values 
     #of the other cells in the set
    def eliminateChoices(cell)
      if (value = cell.hasFinalValue)
            cell.mark
            [@boxes[cell.box],@rows[cell.row],@cols[cell.col]].each do |set|
                eliminateChoiceFromSet(set, cell, value)
            end
        end
    end

    def eliminateChoiceFromSet(g, exceptCell, n)
        g.each {|cell| eliminateValueFromCell(n,cell) if cell != exceptCell }
    end

    def eliminateValueFromCell(value, cell)
        @queue << cell if cell.eliminate(value) && !@queue.include?(cell)
    end

    def checkForKnownValues()
        @size.times do |n|
            [@rows[n],@cols[n],@boxes[n]].each do |set|
                findPairs(set)
                findUniqueChoices(set)
            end
        end
    end

    def findUniqueChoices(set)
        1.upto(@size) do |n| #check for every possible value
            lastCell = nil
            set.each do |c|  #in every cell in the set
                if (c.includes?(n))
                    if (c.hasFinalValue || lastCell)  
                        #found a 2nd instance, no good 
                        lastCell = nil
                        break
                    end
                    lastCell = c;
                end 
            end 
            #if true, there is only one cell in the set with that value, 
            #so let it be the answer
            if (lastCell && !lastCell.hasFinalValue) 
                lastCell.set(n)
                @queue << lastCell
            end
        end
    end 

    #find any pair of cells in a set with the same 2 possibilities 
    # - these two can be removed from any other cell in the same set
    def findPairs(set)
        0.upto(@size-1) do |n|
            (n+1).upto(@size-1) do |m|
                if (set[n].possible.size == 2 && set[n].possible ==
set[m].possible)
                    eliminateExcept(set, [m,n], set[n].possible)
                end
            end
        end
    end

    #for every cell in a set except those in the skiplist, eliminate the values
    def eliminateExcept(set, skipList, values)
        @size.times do |n|  
            if (!skipList.include?(n)) 
                values.each {|v| eliminateValueFromCell(v, set[n])}  
            end
        end
    end

    def startGuessing
        print "Only Solveable by Guessing\n" if @level == 1
        while (c = unsolved) 
                myclone = Solver.new(boardlist,@size, true,@level)
                myguess = myclone.guess
                return false if !myguess
                dprint myclone
            begin
                if (myclone.solve)
                    become(myclone.boardlist)
                    return true
                else 
                    return false
                end
            rescue BadGuessException 
                #this is the big speedup - remove the bad guess 
                #from the possibilities, and re-solve
                @queue << myguess.remove(@rows) 
                dprint "#{@level} Bad Guess\n #{self}"
                return solve    
            end
        end
    end

    def guess
    	2.upto(@size) do |min|
    		@boxes.each do |set| 
    			set.each do |cell|
    				if cell.possible.size == min
    					g = Guess.new(cell)
    					cell.set(g.value)
    					@queue << cell
    					dprint g
    					return g
    				end
    			end
    		end
    	end
    	dprint "did not find a guess\n"
        return nil
    end

    #formating (vertical line every cbreak)
    def showBorder(cbreak)
        s = "+"
        1.upto(@size) do |n|
            s << "--"
            s<< "-+" if ((n)%cbreak == 0)
        end
        s <<"\n"
    end

    def to_s
        r=c=0
        cbreak,rbreak = GetBoxBounds(@size)
        s = showBorder(cbreak)
        @rows.each do |row| 
            #r+=1
            s << "|"
            row.each do |cell| 
                c+=1
                s << cell.to_s
                if (c==cbreak) then s << " |";c=0; end
            end
            s<<"\n"
            if (r+=1)==rbreak then s << showBorder(cbreak); r=0; end
        end
        s<<"\n"
        s
    end

    def boardlist
        a = []
        @rows.each do |row| 
            row.each do |cell| 
                v = cell.hasFinalValue
                a<< ( v ? v : cell.possible )
            end
        end
        a
    end

end

#parses text file containing board.  The only significant characters are _, 0-9, A-Z.
# if bounded by +---+---+---+, uses the + char to determine the layout of the boxes
#there must be an equal number of significant chars in each line, and the same number of rows.
def ParseBoard(file)
    row = 0
    col = 0
    boxes = 0
    boardlist = [ ]
    file.each do |line|
        line.chomp.each_byte do |c|
            case c
                when ?0..?9
                    boardlist << c.to_i - ?0
                    col+=1
                when ?A..?Z
                    boardlist << c.to_i - ?A + 10
                    col+=1
                when ?a..?z
                    boardlist << c.to_i - ?a + 10
                    col+=1
                when ?_
                    boardlist << -1
                    col+=1
                when ?+
                     boxes+=1 if row == 0
            end
        end
        if (col > 0)  then 
            row+=1 
            break if (row == col) 
        end
        col=0
    end
    @@boxcols = boxes-1
    return boardlist,row
end

if __FILE__ == $0
    boardlist, size = ParseBoard(ARGF) 
    sol = Solver.new(boardlist, size)

    print sol
    begin
        print "UNSOLVABLE\n" if (!sol.solve()) 
    rescue BadGuessException
        print "Malformed Puzzle\n"
    end
    print sol
end
