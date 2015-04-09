(1..100).each{ |x|
   out=""
   (!!((x%3).zero? && out<<"Fizz") & !!((x%5).zero? && out<<"Buzz"))
   out=x if out==""
   puts out }
end
