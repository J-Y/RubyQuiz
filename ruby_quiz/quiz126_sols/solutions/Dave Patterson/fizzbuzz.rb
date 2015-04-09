 (1..100).each {|x|
    temp = (x%3==0) ? "Fizz" : ""
    temp += (x%5==0) ? "Buzz" : ""
    puts (temp.size==0) ? x : temp     
}
