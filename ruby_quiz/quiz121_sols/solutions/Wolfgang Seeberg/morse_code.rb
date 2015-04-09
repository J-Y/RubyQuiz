# Usage: ruby q121.rb
# displays all possible letter sequences for a line of morse code.

Morsehash = Hash[*%w(
    a .-     b -...   c -.-.   d -..    e .      f ..-.   g --.
    h ....   i ..     j .---   k -.-    l .-..   m --     n -.
    o ---    p .--.   q --.-   r .-.    s ...    t -      u ..-
    v ...-   w .--    x -..-   y -.--   z --..
)]

Dictionary = Hash[*%w(ruby i ieee sos).collect{ | x | [x, 1] }.flatten]

def eat(morsecode, string = "")
    if morsecode == ""
        printf "  in dictionary: " if Dictionary.has_key?(string)
        puts string
    else
        Morsehash.each do | letter, code |
            if morsecode[0, code.size] == code
                eat(morsecode[code.size .. -1], string + letter)
            end
        end
    end
end

STDERR.printf "enter morse code: "
while gets
    eat($_.tr("^---.", ""))
end
