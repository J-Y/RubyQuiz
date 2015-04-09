ARABIC = {"I" => 1, "IV" => 4, "V" => 5, "IX" => 9, "X" => 10, "XL" => 40, 
"L" => 50, "XC" => 90, "C" => 100, "CD" => 400, "D" => 500, "CM" => 900, 
"M" => 1000} 
ROMAN = ARABIC.invert 


def toInt(roman) 
    roman.reverse.split(//).inject(0) do |acc, letter| 
        acc += ARABIC[letter] * (acc > ARABIC[letter] * 3 ? -1 : 1) 
    end 
end 


def toRoman(number) 
    ARABIC.values.sort.reverse.inject("") do |acc, value| 
        mult, number = number.divmod(value) 
        acc << ROMAN[value] * mult 
    end   
end 


STDIN.readlines.each{|line| line.chomp!; print line, " = ", (line.to_i > 0 ?  toRoman(line.to_i) : toInt(line)), "\n"} 
