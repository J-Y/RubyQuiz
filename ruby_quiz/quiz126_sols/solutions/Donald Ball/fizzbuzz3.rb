puts (1..100).map{|n|n%15>0?n%5>0?n%3>0?n:'fizz':'buzz':'fizzbuzz'}