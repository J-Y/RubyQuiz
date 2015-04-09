def make_change(amount, coins=[25,10,5,1])
#initialise
amt_orig=amount
change=[]
indx=0

#this works it out!
while amount>0
divarray=amount.divmod(coins[indx])
change.push(divarray[0])
amount=divarray[1]
indx+=1
end

#display result
s=amt_orig.to_s+ " requires: "
puts(s)
for i in 0..3
unless change[i]==nil
s=change[i].to_s+" of coins of value "+coins[i].to_s
puts(s)
end
end
end
