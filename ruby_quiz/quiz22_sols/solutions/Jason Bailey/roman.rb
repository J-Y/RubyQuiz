#!/usr/bin/env ruby

@data = [
["M"  , 1000],
["CM" , 900],
["D"  , 500],
["CD" , 400],
["C"  , 100],
["XC" ,  90],
["L"  ,  50],
["XL" ,  40],
["X"  ,  10],
["IX" ,   9],
["V"  ,   5],
["IV" ,   4],
["I"  ,   1]
]

@roman = %r{^[CDILMVX]*$}
@arabic = %r{^[0-9]*$}

def toRoman(num)
    reply = ""
    for key, value in @data
        count, num = num.divmod(value)
        reply << (key * count)
    end
    reply
end

def toArabic(rom)
    reply = 0
    for key, value in @data
        while rom.index(key) == 0
            reply += value
            rom.slice!(key)
        end
    end
    reply
end

$stdin.each do |line|
    case line
    when @roman
        puts toArabic(line)
    when @arabic
        puts toRoman(line.to_i)
    end
end
