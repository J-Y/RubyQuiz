#! /usr/bin/ruby

class MagicSquare
  def initialize( ord )
    @ord = ord

    checkOrd
    initSquare
    makeSquare
    printNiceSquare
  end

  def checkOrd
    if @ord%2 != 1 || @ord < 0
      puts "Not implemented or not possible..."
      exit
    end
  end

  def setCoord( row, col, number )
    loop do
      if @square[row][col].nil?
        @square[row][col] = number
        @oldCoord = [row, col]
        return
      else
        row = @oldCoord[0] + 1
        col = @oldCoord[1]
        row -= @ord if row >= @ord
      end
    end
  end

  def initSquare
    @square = Array.new(@ord)
    @square.each_index do |row|
      @square[row] = Array.new(@ord)
    end
  end

  def makeSquare
    (@ord**2).times do |i|
      setNewCoord( i + 1 )
    end
  end

  def setNewCoord( i )
    if @oldCoord.nil?
      setCoord(0, (@ord + 1)/2-1, i)
    else
      row = @oldCoord[0] + 2
      col = @oldCoord[1] + 1

      row -= @ord if row >= @ord
      col -= @ord if col >= @ord

      setCoord(row, col, i)
    end
  end

  def printNiceSquare
    width = (@ord**2).to_s.length

    @square.each do |row|
      row.each do |nr|
        nr = nr.nil? ? "." : nr
        spaces = width - nr.to_s.length
        print " "*spaces + "#{nr}" + "  "
      end
      puts
    end
  end
end

ord = ARGV[0].to_i
MagicSquare.new( ord )
