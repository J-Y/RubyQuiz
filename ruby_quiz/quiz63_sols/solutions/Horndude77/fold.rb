#!/usr/bin/ruby -w

module Math
    def Math.lg(n) log(n)/log(2) end
end

def fold(s, n)
    #validate inputs
    pow = Math.lg(n)
    raise "Bad dimension" if pow != pow.round
    raise "Bad string length" if s.length != (pow*2).round
    horiz, vert = 0, 0
    s.downcase.split('').each do |orient|
        case orient
        when 'r', 'l'
            vert += 1
        when 't', 'b'
            horiz += 1
        end
    end
    raise "Unbalanced folds" if horiz != vert

    #do the folding
    max = n**2
    stack = Array.new(max)
    1.upto(max) do |i|
        row, col, pos, height = (i-1)/n, (i-1)%n, 0, 1
        x, y = n, n
        s.each_byte do |move|
            pos += height
            height *= 2
            case move
            when ?L
                x /= 2
                if col < x then
                    col = x-col-1
                    pos = height - pos - 1
                else
                    col -= x
                end
            when ?R
                x /= 2
                if col >= x then
                    col = x*2 - col - 1
                    pos = height - pos - 1
                end
            when ?T
                y /= 2
                if row < y then
                    row = y-row-1
                    pos = height - pos - 1
                else
                    row -= y
                end
            when ?B
                y /= 2
                if row >= y then
                    row = y*2 - row - 1
                    pos = height - pos - 1
                end
            end
        end
        stack[pos] = i
    end
    stack
end

def same_row?(a,b,n)
    (a-1)/n == (b-1)/n
end

def same_col?(a,b,n)
    (a-1)%n == (b-1)%n
end

def unfold(stack, recurse = :yes)
    pow = Math.lg(stack.length)
    raise "Bad dimension" unless pow == pow.round && (pow.round % 2) == 
0
    side = Math.sqrt(stack.length).round
    s = ""
    while stack.length > 1
        half = stack.length/2
        a, b = stack[half-1], stack[half]
        if same_row? a, b, side then
            if a<b then s << 'L' else s << 'R' end
        elsif same_col? a, b, side then
            if a<b then s << 'T' else s << 'B' end
        else
            raise "Stack not generated from folding"
        end
        stack = stack[half, half]
    end

    s.reverse!
    if(recurse == :yes) then
        unfold(fold(s, side), :no)
    else
        s
    end
end
