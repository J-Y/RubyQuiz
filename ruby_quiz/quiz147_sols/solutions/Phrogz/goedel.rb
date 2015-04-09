PRIMES = DATA.read.split(/\s+/).map{ |s| s.to_i }

module Enumerable
  def inject_with_index( *arg )
    idx = -1
    inject(*arg){ |memo,obj| yield( memo, obj, idx += 1 ) }
  end
end

class Integer
  def to_binary
    hex_string = to_s(16)
    hex_string = "0#{hex_string}" if (hex_string.length % 2) == 1
    [ hex_string ].pack( 'H*' )
  end
  def self.from_binary( binary_string )
    binary_string.unpack( 'H*' )[ 0 ].to_i( 16 )
  end
end

class String
  def to_godel
    split(//).inject_with_index(1){ |prod,s,i| prod * PRIMES[i]**(s[0]+1) }
  end
  def self.from_godel( int )
    # TODO - steal from someone else's solution :)
  end

  def to_godel_binary
    to_godel.to_binary
  end
  def self.from_godel_binary( binary_string )
    from_godel( Integer.from_binary( binary_string ) )
  end
end

source = "Ruby\n"
p source.to_godel, source.to_godel.to_s.length
#=> 10992805522291106558517740012022207329045811217010725353610920778286647492334024539853797606781498669917422059828200399558722467748602915924849555388215835147992284043337570190429687500000000000000000000000000000000000000000000000000000000000000000000000000000000000
#=> 266

p source.to_godel_binary, source.to_godel_binary.length
#=> "\025\321\241\301d\266\253\317\366\246\361\242\226W\247\300\253\025\345p\326\325=\2569yp\005HY\231\006\354\371;TV\224\335\b\321\317\230\004\315Hk2?\345\314\365\212\017H\2456@\224\303\204\244\346\005\205\273\331\031]K\030\370\207di\216\035\247\262\255I\353\355\256\016\250\e\377{r\260\037\324\354-\304\212\025!\337\200\000\000\000\000\000\000\000\000\000\000"
#=> 111

# A few primes only, trimmed for posting; add more for larger messages
__END__
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103
107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199
211 223 227 229 233 239 241 251 257 263 269 271 277 281 283 293 307 311 313
317 331 337 347 349 353 359 367 373 379 383 389 397 401 409 419 421 431 433
439 443 449 457 461 463 467 479 487 491 499 503 509 521 523 541 547 557 563
569 571 577 587 593 599 601 607 613 617 619 631 641 643 647 653 659 661 673
677 683 691 701 709 719 727 733 739 743 751 757 761 769 773 787 797 809 811
821 823 827 829 839 853 857 859 863 877 881 883 887 907 911 919 929 937 941

