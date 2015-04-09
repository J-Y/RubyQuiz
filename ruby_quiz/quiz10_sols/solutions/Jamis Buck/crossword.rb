##########################################################################
# Jamis Buck's solution to Ruby-Quiz #10:
##########################################################################

module Layout

  class Definition
    def initialize( string )
      @lines = string.split( $/ ).map { |l| l.gsub(/\s/,"") }
      @properties = Hash.new
    end

    def rows
      @lines.length
    end

    def columns
      @lines.first.length
    end

    def []( x, y )
      return false if ( x < 0 ) || ( y < 0 )
      return false if ( x >= columns ) || ( y >= rows )
      @lines[y][x] == ?_
    end

    def property( x, y, name )
      @properties[ [x,y,name] ]
    end

    def set_property( x, y, name, value )
      @properties[ [x,y,name] ] = value
    end
  end

  class Formatter
    def initialize( definition )
      @definition = definition
    end

    CELL_WIDTH = 5
    CELL_HEIGHT = 3

    NUMBER_TOKEN = "%-3s"

    FILLED_CELL = [ "#####", "#####", "#####" ]
    EMPTY_CELL = [ "#####", "##{NUMBER_TOKEN} ", "#    " ]
    BLANK_CELL = [ "`^^^^", "<    ", "<    " ]

    WALL = "#"
    SPACE = " "

    def format( output=STDOUT )
      number = 1
      @definition.rows.times do |row|
        CELL_HEIGHT.times do |row_y|
          @definition.columns.times do |col|
            cell = @definition[col,row] ? EMPTY_CELL : FILLED_CELL
            line = cell[row_y]

            number_str = ""
            if cell[row_y].include?(NUMBER_TOKEN) && @definition[col,row]
              if ( !@definition[col-1,row] && @definition[col+1,row] ) ||
                 ( !@definition[col,row-1] && @definition[col,row+1] )
              # begin
                number_str = number.to_s
                number += 1
              end
            elsif !@definition[col,row]
              if has_exit_path( col, row )
                line = BLANK_CELL[row_y]
                clear_left = has_exit_path( col-1, row )
                clear_up = has_exit_path( col, row-1 )
                clear_corner = has_exit_path( col-1, row-1 )
                up_char = clear_up ? SPACE : WALL
                left_char = clear_left ? SPACE : WALL
                corner_char = clear_corner && clear_left && clear_up ?
                  SPACE : WALL
                line = line.tr( "`^<", "#{corner_char}#{up_char}#{left_char}" )
              else
                @definition.set_property( col, row, :exit_path, false )
              end
            end

            output << line % number_str
          end
          puts( @definition[@definition.columns-1,row-1] &&
            row_y == 0 || @definition[@definition.columns-1,row] ?
            WALL : SPACE )
        end
      end

      @definition.columns.times do |col|
        if !@definition[col,@definition.rows-1]
          if col == 0 || col > 0 && !@definition[col-1,@definition.rows-1]
            print SPACE
          else
            print WALL
          end
          print SPACE*4
        else
          print WALL*5
        end
      end

      if @definition[@definition.columns-1,@definition.rows-1]
        print WALL
      end

      puts
    end

    def has_exit_path( col, row )
      @visited = Hash.new
      find_exit_path_recurse( col, row )
    end
    private :has_exit_path

    def find_exit_path_recurse( col, row )
      return false if @definition[col,row]
      return false if @visited[ [col,row] ]
      @visited[ [col,row] ] = true

      return true if @definition.property( col, row, :exit_path )
      return false if @definition.property( col, row, :exit_path ) == false

      if col == 0 || col == @definition.columns-1 ||
         row == 0 || row == @definition.rows-1
      #begin
        @definition.set_property( col, row, :exit_path, true )
        return true
      end

      found = ( col > 0 && !@definition[col-1,row] &&
        find_exit_path_recurse( col-1, row ) )

      found = found || ( col < @definition.columns-1 &&
        !@definition[col+1,row] && find_exit_path_recurse( col+1, row ) )

      found = found || ( row > 0 && !@definition[col,row-1] &&
        find_exit_path_recurse( col, row-1 ) )

      found = found || ( row < @definition.rows-1 && !@definition[col,row+1] &&
        find_exit_path_recurse( col, row+1 ) )

      if found
        @definition.set_property( col, row, :exit_path, true )
        return true
      end

      return false
    end
    private :find_exit_path_recurse

  end

  def format( file, output=STDOUT )
    definition = Definition.new( File.read( file ) )
    Formatter.new( definition ).format( output )
  end
  module_function :format

end

Layout.format( ARGV.first, STDOUT ) if __FILE__ == $0
