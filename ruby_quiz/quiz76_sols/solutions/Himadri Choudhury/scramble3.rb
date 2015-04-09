print ARGF.read.gsub!(/\B[a-z]+\B/) {|x|
    x.length.times {|i|
        j = rand(i+1)
        x[j], x[i] = x[i] , x[j]
    }
    x
}
