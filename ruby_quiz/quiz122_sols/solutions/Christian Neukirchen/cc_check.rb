#!ruby

def cardtype(n)
  case n.delete("^0-9")
  when /\A3[37]\d{13}\z/:   "AMEX"
  when /\A6011\d{12}\z/:    "Discover"
  when /\A5[1-4]\d{14}\z/:  "Master Card"
  when /\A4\d{12}\d{3}?\z/: "Visa"
  else "Unknown"
  end
end

def luhn?(n)
  f = 2
  (n.delete("^0-9").reverse.split(//).map{|d|d.to_i}.
     inject(0) { |a,e| f=3-f; a + (e*f > 9 ? e*f-9 : e*f) } % 10).zero?
end

puts cardtype(ARGV.join)
puts luhn?(ARGV.join) ? "valid" : "invalid"
