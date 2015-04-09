require 'goedel.rb'
require 'benchmark'
include Benchmark          # we need the CAPTION and FMTSTR constants

plaintext = "Below are listed the first prime numbers of many named forms and types. More details are in the article for the name. n is a natural number (including 0) in the definitions."
#plaintext = "Sometimes benchmark results are skewed because code executed earlier encounters different garbage collection overheads 
#than that run later. bmbm attempts to minimize this effect by running the tests twice, the first time as a rehearsal in order to 
#get the runtime environment stable, the second time for real. GC.start is executed before the start of each of the real timings; 
#the cost of this is not included in the timings. In reality, though, there‘s only so much that bmbm can do, and the results are 
#not guaranteed to be isolated from garbage collection and other effects."
puts "Number of Primes: GoedelCipher::Primes.size = #{GoedelCipher::Primes.size}"
    
Benchmark.benchmark("\t"*2 + CAPTION, 7, FMTSTR, ">total:", ">avg:") do |b|
  #tf = b.report("standard\t")   { 
  #  msg = GoedelCipher.encrypt(plaintext)
  #  text = GoedelCipher.decrypt(msg)
  #}
  tf = b.report("large (default)\t")   { 
    msg = GoedelCipher.large_encrypt(plaintext, GoedelCipher::Primes.size)
    text = GoedelCipher.large_decrypt(msg)
  }
  tf = b.report("large (def/2)\t")   { 
    msg = GoedelCipher.large_encrypt(plaintext, GoedelCipher::Primes.size / 2)
    text = GoedelCipher.large_decrypt(msg)
  }
  tf = b.report("large (def/4)\t")   { 
    msg = GoedelCipher.large_encrypt(plaintext, GoedelCipher::Primes.size / 4)
    text = GoedelCipher.large_decrypt(msg)
  }
  tf = b.report("large (16)\t")   { 
    msg = GoedelCipher.large_encrypt(plaintext, 16)
    text = GoedelCipher.large_decrypt(msg)
  }  
end
