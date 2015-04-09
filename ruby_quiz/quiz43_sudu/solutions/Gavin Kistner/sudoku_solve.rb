module Soduku
    class Board
        attr_reader :spaces, :tiles, :rows, :cols
        def initialize( board_to_load=nil )
            @spaces = (0..80).to_a.map{ |i| Space.new }

            @rows = []
            0.step( 80, 9 ){ |i|
                @rows << @spaces[ i..(i+8) ]
            }

            @cols = []
            0.upto( 8 ){ |i|
                @cols << col = []
                0.step( 80, 9 ){ |j|
                    col << @spaces[ i+j ]
                }
            }

            @tiles = []
            0.step(54,27){ |a|
                0.step(6,3){ |b|
                    @tiles << tile = []
                    corner = a+b
                    0.step(18,9){ |row_offset|
                        0.upto(2){ |col_offset|
                            tile << @spaces[ corner + row_offset + col_offset ]
                        }
                    }
                }
            }

            if board_to_load
                values = board_to_load.scan( /[\d_]/ )
                raise "Supplied board does not have 81 distinct values" unless values.length == 81
                values.each_with_index{ |v,i|
                    @spaces[i].value = v.to_i if v != '_'
                }
            end
        end

        def solve
            unsolved_count = 81
            iteration = 1
            row_solved = {}
            col_solved = {}
            tile_solved = {}

            while unsolved_count > 0 && iteration < 100
                puts "Iteration #{iteration}" if $DEBUG
                unsolved_count = 81 - @spaces.select{ |s| s.value }.length
                puts "\t#{unsolved_count} spaces unsolved" if $DEBUG

                @rows.each_with_index{ |row,i|
                    unless row_solved[i]
                        if solve_set( row )
                            row_solved[i] = true
                        end
                    end
                }

                @cols.each_with_index{ |col,i|
                    unless col_solved[i]
                        if solve_set( col )
                            col_solved[i] = true
                        end
                    end
                }

                @tiles.each_with_index{ |tile,i|
                    unless tile_solved[i]
                        if solve_set( tile )
                            tile_solved[i] = true
                        end
                    end
                }

                iteration += 1
            end
        end

        def synchronize
            @spaces.each{ |s| s.synchronize }
        end

        def to_s
            row_sep = "+-------+-------+-------+\n"
            out = ''
            @spaces.each_with_index{ |s,i|
                out << row_sep if i % 27 == 0
                out << '| '    if i % 3 == 0
                out << s.to_s + ' '
                out << "|\n" if i % 9 == 8
            }
            out << row_sep
            out
        end

        private
            def solve_set( spaces )
                unknown_spaces = spaces.select{ |s| !s.value }
                return true if unknown_spaces.length == 0
                known_spaces = spaces - unknown_spaces
                known_values = known_spaces.collect{ |s| s.value }
                unknown_spaces.each{ |s|
                    possibles = s.possibles
                    known_values.each{ |v| possibles.delete( v ) }
                    s.synchronize
                }
                # Recheck now that they've all been synchronized
                unknown_spaces = spaces.select{ |s| !s.value }
                return true if unknown_spaces.length == 0
                return false
            end

    end

    class Space
        attr_accessor :value, :possibles
        def initialize( value=nil )
            @possibles = {}
            unless @value = value
                1.upto(9){ |i| @possibles[i]=true }
            end
        end
        def synchronize
            possible_numbers = @possibles.keys
            if possible_numbers.length == 1
                @value = possible_numbers.first
            end
        end
        def to_s
            @value ? @value.to_s : '_'
        end
    end
end

b = Soduku::Board.new( <<ENDBOARD )
+-------+-------+-------+
| 9 6 3 | 1 7 4 | 2 5 _ |
| _ _ 8 | 3 _ 5 | 6 4 9 |
| 2 _ _ | _ _ _ | 7 _ 1 |
+-------+-------+-------+
| 8 _ _ | 4 _ 7 | _ _ 6 |
| _ _ 6 | _ _ _ | 3 _ _ |
| 7 _ _ | 9 _ 1 | _ _ 4 |
+-------+-------+-------+
| 5 _ _ | _ _ _ | _ _ 2 |
| _ _ 7 | 2 _ 6 | 9 _ _ |
| _ 4 _ | 5 _ 8 | _ 7 _ |
+-------+-------+-------+
ENDBOARD

$DEBUG = true
puts b
b.solve
puts b
