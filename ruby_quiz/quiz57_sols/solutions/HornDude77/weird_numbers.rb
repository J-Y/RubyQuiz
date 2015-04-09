class Integer
    def divisors
        divs = []
        1.upto(Math.sqrt(self).to_i) do |i|
            divs += [i ,self/i].uniq if (self%i == 0)
        end
        divs.sort.reverse #reverse speeds things up a bit
    end

    def weird?
        divs = self.divisors - [self]
        return false if divs.sum < self
        divs.each_combination do |comb|
            return false if comb.sum == self
        end
        return true
    end
end

class Array
    def each_combination
        (2**self.length).times do |comb|
            curr = []
            self.length.times do |index|
                curr << self[index] if(comb[index] == 1)
            end
            yield curr
        end
    end

    def sum
        inject(0) { |sum, i| sum + i }
    end
end

max = (ARGV[0] || 10000).to_i

max.times do |i|
    puts i if i.weird?
end
