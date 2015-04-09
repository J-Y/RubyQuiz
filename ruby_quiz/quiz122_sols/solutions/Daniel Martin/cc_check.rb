#!ruby -x
def type(s)
    case s.gsub(/\D/,'')
    when /^(?=34).{15}$/; "AMEX"
    when /^(?=37).{15}$/; "AMEX"
    when /^(?=6011).{16}$/; "Discover"
    when /^(?=5[1-5]).{16}$/; "MasterCard"
    when /^(?=4).{13}(...)?$/; "Visa"
    else ; "Unknown"
    end
end

def luhn(s)
  s.scan(/\d/).map{|x|x.to_i}.inject([0,0]){
  |(a,b),c|[b+c%9,a+2*c%9]}[0]%10 == s.scan(/9/).size%10
end

s = ARGV.join
puts "#{type(s)} #{luhn(s)?'V':'Inv'}alid"
