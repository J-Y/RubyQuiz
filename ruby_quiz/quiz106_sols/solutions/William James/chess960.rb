which = ( ARGV.first || rand(960) + 1 ).to_i
count = 0

(1..6).each{|k|
  (0...k).each{|r1|
    (k+1..7).each{|r2|
      ((0..7).to_a - [k,r1,r2]).each{|q|
        used = [k,r1,r2,q]
        ((0..7).select{|i| i % 2 == 0} - used).each{|b1|
          ((0..7).select{|i| i % 2 == 1} - used).each{|b2|
            count += 1
            if which == count
              puts "Position #{ count }"
              s = 'N' * 8
              [k,q,r1,r2,b1,b2].zip(%w(K Q R R B B)).each{|i,p|
                s[i] = p }
              puts s.downcase,'p'*8,('.'*8+"\n")*4,'P'*8,s
            end   } } } } } }
