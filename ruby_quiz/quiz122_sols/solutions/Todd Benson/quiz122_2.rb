# preliminary data
sum=known=false;type='';t=0
db = {
  3.4*10**14..3.5*10**14-1 => "AMEX",
  3.7*10**14..3.8*10**14-1 => "AMEX",
  6.011*10**15..6.012*10**15-1 => "Discover",
  5.1*10**15..5.6*10**15-1 => "MasterCard",
  4*10**12..5*10**12-1 => "Visa",
  4*10**15..5*10**15-1 => "Visa",
}

# check stuff
db.each { |k,v| type=v if
k===$*[0].to_i};known||=type!=''
($*[0].reverse.scan(/\d/).map!{|d|d.to_i}).each_with_index{|d,i|t+=(i%2==0
? d : d.divmod(5)[1]*2+d.divmod(5)[0])};sum||=t%10==0

# cryptically print results
puts "Known: #{known}\nType: #{type}\nValid sum: #{sum}"
