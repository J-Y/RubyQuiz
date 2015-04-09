require 'goedel.rb'

if ARGV.size != 1
  puts "Usage: goedel_cmb.rb message_text"
else
  msg = GoedelCipher.large_encrypt(ARGV[0])
  puts "Encrypted Message: #{msg}"
  
  plaintext = GoedelCipher.large_decrypt(msg)
  puts "Decrypted Message: #{plaintext}"
end