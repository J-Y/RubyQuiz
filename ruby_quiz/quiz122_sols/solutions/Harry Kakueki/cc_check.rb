######
# Check Starting numbers and length
def card_ok(str,info)
check = "UNKNOWN"
info.each do |t|
pref = t[0]
leng = t[1]
name = t[2]
  pref.each do |x|
    if x == str.slice(0...x.length)
      leng.each do |y|
        if y.to_i == str.length
        check = name.dup
        end
      end
    end
  end
end
return check
end

# Check Luhn algorithm
def luhn(str)
luhn_hash = Hash.new("INVALID")
if str.length != 0
luhn_hash[0] =  "VALID"
arr = str.split(//).reverse
arr2 = []
arr3 = []
  (0...arr.length).each do |u|
  arr2 << arr[u] if u %2 == 0
  arr2 << (arr[u].to_i * 2).to_s if u %2 != 0
  end

  arr2.each do |r|
  arr3 << r.split(//).inject(0) {|sum,i| sum + i.to_i}
  end

val = arr3.inject(0) {|sum,i| sum + i} % 10
end
return luhn_hash[val]
end

# Card information
test = []
test << [["31","34"],["15"],"AMEX"]
test << [["6011"],["16"],"DISCOVER"]
test << [("51".."55").to_a,["16"],"MASTERCARD"]
test << [["4"],["13","16"],"VISA"]
#test << [("3528".."3589").to_a,["16"],"JCB"]
#test << [[("3000".."3029").to_a + ("3040".."3059").to_a +
#("3815".."3889").to_a + ["36","389"]].flatten!,["14"],"DINERS"]

# Main
str = ARGV.join
arr = []
arr << card_ok(str,test)
arr << luhn(str)
puts arr
