ARABIC = {"I" => 1, "IV" => 4, "V" => 5, "IX" => 9, "X" => 10, "XL" => 40, 
"L" => 50, "XC" => 90, "C" => 100, "CD" => 400, "D" => 500, "CM" => 900, 
"M" => 1000} 
ROMAN = ARABIC.invert 


class String 
    def roman_to_i() 
        self.reverse.split(//).inject( 0) do |acc, letter| 
            acc += ARABIC[letter] * (acc > ARABIC[letter] * 3 ? -1 : 1) 
        end 
    end 
end 


class Integer 
    def to_roman() 
        remainder = self 
        ARABIC.values.sort.reverse.inj ect("") do |acc, value| 
            mult, remainder = remainder.divmod(value) 
            acc << ROMAN[value] * mult 
        end 
    end 
end 


STDIN.readlines.each{|line| line.chomp!; print line, " = ", line.to_i > 0 ? 
line.to_i.to_roman : line.roman_to_i, "\n"} 
