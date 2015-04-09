#!/usr/bin/ruby
# Written by Andrey Falko

def factor(n)
       factors = []

       if (n < 8)
               factors.push(n)
               return factors
       end

       itr = 4
       itr = (n / 4).to_i if (n < 25)
       while (itr < n - (n / 2) + 1)
               if (n % (itr) == 0)
                       factors.concat(factor(itr))
                       factors.concat(factor(n / itr))
               else
                       itr = itr + 1
                       next
               end

               itr = itr + 1
               prod = 1
               for num in factors
                       prod = prod * num
               end

               return factors if (prod == n)
       end

       factors.push(n) if (factors.length == 0) # Primes

       return factors
end

def count(picks)
       cnt = 0
       strs = picks.split('x')
       for str in strs
               cnt += 2
               cnt += str.length
               cnt += 1 if (str =~ /\+/)
       end

       return cnt - 2
end

def minPicks(n)
       if (n <= 8)
               return '|' * n
       else
               factors = factor(n)
               str = ''
               if ((factors.length == 1 && factors[0] == n && n > 11) || n == 34)
                       len = n
                       itr = 1
                       while (8 < n - itr)
                               try = minPicks(n - itr) + '+' + ('|' * itr)
                               itr += 1
                               if (len > (tmp = count(try)))
                                       len = tmp
                                       store = try
                               end
                       end

                       return store
               end

               for fac in factors
                       if (fac == n && n <= 11) # Primes <= 11
                               return '|' * n
                       else
                               str = str + minPicks(fac) + 'x'
                       end
               end

               str = str.gsub(/x$/, '')
               return str
       end
end

n = $*[0].to_i
picks = minPicks(n)

print n.to_s + ": " + picks.to_s + " (" + count(picks).to_s + " toothpicks)\n"
