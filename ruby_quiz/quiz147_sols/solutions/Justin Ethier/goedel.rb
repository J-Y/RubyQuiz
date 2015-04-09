=begin
Justin Ethier
November 2007
Solution to Ruby Quiz 147 - http://www.rubyquiz.com/quiz147.html
=end

#=begin

#any more than x and you need to split the encrypted msg into multiple blocks
#=end

module GoedelCipher
  # Use first 256 prime numbers from: http://en.wikipedia.org/wiki/List_of_prime_numbers
  Primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 
            137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269,  271, 
            277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431,  433, 
            439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599,  601, 
            607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761,  769, 
            773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947,  953, 
            967, 971, 977, 983, 991, 997, 1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103, 
            1109, 1117, 1123, 1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231, 1237, 1249, 1259, 1277, 1279, 
            1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373, 1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 1447, 
            1451, 1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 1579, 1583, 1597, 
            1601, 1607, 1609, 1613, 1619]

  def GoedelCipher.encrypt(plain_text)
    ascii = plain_text.split("").map{|c| c[0]}
    
    msg = 1
    for i in 0...ascii.size
      pwr = ascii[i] == ' ' ? 0 : (ascii[i] + 1)
      msg *= Primes[i] ** pwr
    end
    
    msg
  end
  
  def GoedelCipher.decrypt(msg)
    # decoding: see http://www.math.ksu.edu/~dph/010_readings/Unit1Lesson1.html
    # for an intro to factoring prime numbers.
    # eg: 60=2x3x2x5, so could div 60 by 2 until result%2 != 0
    plain_text = ""
    
    i = 0
    while msg > 1

      letter_count = 0
      while msg % Primes[i] == 0
        letter_count += 1
        msg /= Primes[i]
      end
      
      plain_text += letter_count == 0 ? ' ' : (letter_count - 1).chr
      i += 1 # Move to next prime
    end
    
    plain_text
  end
  
  def GoedelCipher.large_encrypt(plain_text, block_size = Primes.size)
    blocks = []
    for i in 0..(plain_text.size / block_size)
      blocks << encrypt(plain_text[i * block_size, block_size])
    end
    blocks    
  end
  
  def GoedelCipher.large_decrypt(msg)
    msg.map{|block| decrypt(block)}.join
  end  
end

