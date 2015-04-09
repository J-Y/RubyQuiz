#! /usr/bin/env ruby

class Cell

    WIDTH = 6
    HEIGHT = 4

    attr_accessor :neighbors        # Hash, key=:left, :right, :top, :bottom

    def Cell.from_char(c)
        return c == '_' ? WhiteCell.new : BlackCell.new
    end

    def initialize
        @neighbors = {}
    end

    def print_border_at(row, col, paper)
        x = col * (Cell::WIDTH - 1)
        y = row * (Cell::HEIGHT - 1)

        # corners
        paper[y][x] =
            paper[y][x+Cell::WIDTH-1] =
            paper[y+Cell::HEIGHT-1][x] =
            paper[y+Cell::HEIGHT-1][x+Cell::WIDTH-1] = '+'

        # top and bottom
        (Cell::WIDTH-2).times { | j | paper[y][x+1+j] = '-' }
        (Cell::WIDTH-2).times { | j | paper[y+Cell::HEIGHT-1][x+1+j] = '-' }

        # sides
        (Cell::HEIGHT - 2).times { | i |
            paper[y+1+i][x] = '|'
            paper[y+1+i][x+Cell::WIDTH-1] = '|'
        }
    end

end

class WhiteCell < Cell
    attr_accessor :clue_number

    def black?
        return false
    end

    def needs_clue_number?
        return ((@neighbors[:left].nil? || @neighbors[:left].black?) &&
                !@neighbors[:right].nil? && !@neighbors[:right].black?) ||
               ((@neighbors[:top].nil? || @neighbors[:top].black?) &&
                !@neighbors[:bottom].nil? && !@neighbors[:bottom].black?)
    end

    def print_at(row, col, paper)
        print_border_at(row, col, paper)

        if @clue_number
            x = col * (Cell::WIDTH - 1)
            y = row * (Cell::HEIGHT - 1)
            s = @clue_number.to_s
            s.split(//).each_with_index { | char, i |
                paper[y+1][x+1+i] = char
            }
        end
    end
end

class BlackCell < Cell

    def initialize
        super
        @fill_char = '#'
    end

    def black?
        return true
    end

    def hidden?
        return @hidden
    end

    def needs_clue_number?
        return false
    end

    def hide
        return if hidden?
        @hidden = true
        @fill_char = ' '
        @neighbors.each_value { | cell | cell.hide if cell && cell.black? }
    end

    def print_at(row, col, paper)
        return if hidden?

        print_border_at(row, col, paper)

        # fill center
        x = col * (Cell::WIDTH - 1)
        y = row * (Cell::HEIGHT - 1)
         (Cell::HEIGHT-2).times { | i |
            (Cell::WIDTH-2).times { | j | paper[y+1+i][x+1+j] = '#' }
        }
    end

    def print_scanline(i)
        print @fill_char * (Cell::WIDTH - 1)
    end

    def print_bottom
        print_scanline(0)
    end

    def print_right_wall
        print @fill_char
    end
end

class Puzzle

    def initialize(io)
        read_picture(io)
        introduce_neighbors()
        hide_outer_black()
        assign_clue_numbers()
    end

    def read_picture(io)
        @cells = []
        io.each_with_index { | line, i |
            line = line.chomp.gsub(/[^x_]/i, '')
            @cells[i] = []
            line.split(//).each { | c | @cells[i] << Cell.from_char(c) }
        }
    end

    def introduce_neighbors
        @cells.each_with_index { | row, i |
            row.each_with_index { | cell, j |
                cell.neighbors[:left] = @cells[i][j-1] unless j == 0
                cell.neighbors[:right] = @cells[i][j+1]
                cell.neighbors[:top] = @cells[i-1][j] unless i == 0
                cell.neighbors[:bottom] = @cells[i+1][j] if @cells[i+1]
            }
        }
    end

    def hide_outer_black
        @cells.first.each { | cell | cell.hide if cell.black? }
        @cells.last.each { | cell | cell.hide if cell.black? }
        @cells.each { | row |
            row.first.hide if row.first.black?
            row.last.hide if row.last.black?
        }
    end

    def assign_clue_numbers
        clue_number = 1
        @cells.each_with_index { | row, i |
            row.each_with_index { | cell, j |
                if cell.needs_clue_number?
                    cell.clue_number = clue_number
                    clue_number += 1
                end
            }
        }
    end

    def print
        paper = blank_paper
        @cells.each_with_index { | row, row_num |
            row.each_with_index { | cell, col_num |
                cell.print_at(row_num, col_num, paper)
            }
        }
        paper.each { | scanline | puts scanline.join }
    end

    def blank_paper
        width = @cells[0].size * (Cell::WIDTH - 1) + 10
        height = @cells.size * (Cell::HEIGHT - 1) + 10
        paper = []
        height.times { paper << (' ' * width).split(//) }
        return paper
    end

end

Puzzle.new(ARGF).print
