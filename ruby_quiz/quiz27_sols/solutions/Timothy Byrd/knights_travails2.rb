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


     def self.find_path_bf(pStart, pEnd, forbidden)

        # Are we there yet?
        #
        return [pEnd.clone] if pStart == pEnd

        # You can't get there from here!
        #
        return nil if forbidden.include?(pEnd)

        position_list = Hash.new
        forbidden.each {|f| position_list[f] = 'forbidden' }
        position_list[pStart] = []

        moves_to_check = [pStart]

        until moves_to_check.empty? do
            pos = moves_to_check.shift
            possible_moves(pos).each do |m|
                next if position_list[m]
                position_list[m] = position_list[pos] + [m]
                return position_list[m] if m == pEnd
                moves_to_check.push(m)
            end
        end

        nil
    end
end

if ARGV[1]
    Knight.find_path(ARGV[0], ARGV[1], ARGV[2..-1])
else
    Knight.find_path('a8', 'b7', ['b6'])
    Knight.find_path('a8', 'g6', ['b6', 'c7'])
end
