module Knight

    Moves = [
        [-2,-1], [-2, 1], [2,-1], [2, 1],
        [-1,-2], [-1, 2], [1,-2], [1, 2]
    ]

    def self.possible_moves(pos)
        result = []
        mv = 'a1'

        Moves.each {|delta|
            (0..1).each { |i|  mv[i] = pos[i] + delta[i] }
            if (?a..?h).include?(mv[0]) && (?1..?8).include?(mv[1])
                result.push(mv.clone)
            end
        }
        result
    end

    def self.find_path_recurse(pStart, pEnd, forbidden, max_moves = 64)

        # Are we there yet?
        #
        return [pEnd.clone] if pStart == pEnd

        # You can't get there from here!
        #
        return nil if forbidden.include?(pEnd) || max_moves <= 0

        moves = possible_moves(pStart)
        moves.delete_if {|x| forbidden.include?(x)}

        return [pEnd.clone] if moves.include?(pEnd)

        best_solution = nil
        moves_left = max_moves - 1
        cant_go = forbidden.clone.concat(moves)

        moves.each do |m|
            s = find_path_recurse(m, pEnd, cant_go, moves_left)
            next if !s

            s.insert(0, m)
            if !best_solution || s.size < best_solution.size
                # From now on only interested in solutions that
                # are at least two moves shorter
                #
                moves_left = s.size - 2
                best_solution = s
            end
        end

        best_solution
    end


    def self.find_path(pStart, pEnd, forbidden)
        forbidden = [] if !forbidden
        if forbidden.empty?
            puts "From #{pStart} to #{pEnd}"
        else
            puts "From #{pStart} to #{pEnd} excluding
[#{forbidden.join(', ')}]"
        end
        s = find_path_recurse(pStart, pEnd, forbidden, 64)
        if s
            puts s.join(', ')
        else
            puts nil
        end
        puts ''
    end
end

if ARGV[1]
    Knight.find_path(ARGV[0], ARGV[1], ARGV[2..-1])
else
    Knight.find_path('a8', 'b7', ['b6'])
    Knight.find_path('a8', 'g6', ['b6', 'c7'])
end
