class Making_change
$change = []
def make_change(amount,coins=[25,10,5,1])
  @coing = coins
  if amount < 0
     print "amount should be a positive integer \n"
     exit
  end

  coins.each do |i|
     if amount >= i
        $change << i
        amount = amount-i
        redo
     elsif amount == 0
        return $change
     else next
     end
  end
end
end

a = Making_change.new
p a.make_change(52) # => [25,25,1,1]
p a.make_change(52) # => amount should be a positive integer
