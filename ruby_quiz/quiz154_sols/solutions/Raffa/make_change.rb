Node = Struct.new(:amount, :cost, :rest,:coin)
def make_change(amount, coins = [25, 10, 5, 1])
 return [ ] if amount.zero?

 #coins = coins.sort_by { |coin| -coin }

 #@r =Hash.new # rests (indexed)

queue=[amount]
j=0

@matrix=Array.new
@row=Array.new
@amounts=Array.new
@results=Array.new
@rests=Hash.new


 loop do

   amount = queue.shift
   @amounts << amount
   return if amount == nil

   coins.each_with_index do |coin, idxCoin|

     cost=amount/coin
     #cost=nil if amount=0
     rest= amount%coin

     #puts "#{amount}-#{coin}-#{rest}"


     row="#{cost},#{rest}"
     #row="#{cost},#{coin}"
     row = nil if cost==0


     #if cost==0
      # @row << nil
     #else
     #  @row<<"#{cost},#{rest}"
     #end

     @row << row


     #aResult=
     #@results<< "#{cost}*#{coin}" if cost >0  and rest ==0
#Node.new(amount,cost,0,coin) if cost > 0 and rest ==0
     #@rests[rest] ="#{cost}*#{coin}" if cost >0  and rest >0
    #@r[rest] += Node.new(cost,coin)
    #print "- #{rest}"

    queue << rest if cost > 0 and rest >0
    #puts "(#{cost}-#{rest})"
    # p queue.size

     end
     @matrix << @row
     @row=[]

   #return if queue.size> 50

 end

end



if __FILE__ == $PROGRAM_NAME
  amount, *coins = ARGV.map { |n| Integer(n) }
  abort "Usage:  #{$PROGRAM_NAME} AMOUNT [COIN[ COIN]...]" unless
amount

  coins.empty? ? make_change(amount) : make_change(amount, coins)



@matrix.each_with_index {|x,i| puts "*amount:#{@amounts[i]}*" +
x.inspect}
 #puts @results.inspect
 #puts @rests.inspect



end
