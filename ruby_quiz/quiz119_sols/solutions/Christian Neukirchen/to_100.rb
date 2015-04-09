(00000000..'22222222'.to_i(3)).map { |x| x.to_s(3).rjust(8, "0").
                                                   tr('012', '-+ ') }.
  find_all { |x| x.count("-") == 2 and x.count("+") == 1 }.
  map { |x|
    t = "1" + x.split(//).zip((2..9).to_a).join.delete(" ")
    [eval(t), t]
  }.sort.each { |s, x|
    puts "*****************" if s == 100
    puts "#{x}: #{s}"
    puts "*****************" if s == 100
  }
