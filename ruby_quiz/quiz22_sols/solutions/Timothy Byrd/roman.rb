class RomanNumerals 


    Roman_array = [ 
        [ 1000, 'M'  ], 
        [  900, 'CM' ], 
        [  500, 'D'  ], 
        [  400, 'CD' ], 
        [  100, 'C'  ], 
        [   90, 'XC' ], 
        [   50, 'L'  ], 
        [   40, 'XL' ], 
        [   10, 'X'  ], 
        [    9, 'IX' ], 
        [    5, 'V'  ], 
        [    4, 'IV' ], 
        [    1, 'I'  ] 
        ] 


    def self.to_roman(val) 
        if val < 0 or val > 5000 
            "out of range '#{val}'" 
        else 
            s = "" 
            Roman_array.each { |pair| 
                while val >= pair[0] 
                    s << pair[1] 
                    val -= pair[0] 
                end 
            } 
            s 
         end 
    end 


    def self.from_roman(str) 
        value = 0 
        s = str.upcase 


        while s =~ /^(M|CM|D|CD|C|XC|L|XL|X|IX|V| IV|I)/ 
            value += Roman_array.find() { |pair| pair[1] == $1 }[0] 
            s = $'  #postmatch 
        end 


        if !s.empty? 
            value = value.to_s + " with invalid characters '#{s}'" 
        end 


        value 
    end 


    def self.translate(s) 
        if s.to_i > 0 
            to_roman(s.to_i) 
        else 
            from_roman(s) 
        end 
    end 
end 


$<.each_line { |line| puts RomanNumerals.translate(line.c homp) } 
