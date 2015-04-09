# Usage: ruby -s q119.rb [-digits=1234] [-target=0]
$target = ($target or 100).to_i
$digits ||= "123456789"
n = $digits.size()
plus = "+"
minus = "-"
frame = "***********************"
neqn = 0
for i in 1 .. n - 1
    s = $digits * 1
    s[i, 0] = minus
    for j in i + 2 .. n
        t = s * 1
        t[j, 0] = minus
        for k in j + 2 .. n + 1
            u = [t * 1, t * 1, t * 1]
            u[0][k, 0] = plus
            u[1][k, 0] = minus; u[1][j] = plus
            u[2][k, 0] = minus; u[2][i] = plus
            u.each do | item |
                neqn += 1
                r = eval(item)
                result = item + " = " + r.to_s
                if r == $target
                    puts frame, result, frame
                else
                    puts result
                end
            end
        end
    end
end
puts "#{neqn} possible equations tested"
