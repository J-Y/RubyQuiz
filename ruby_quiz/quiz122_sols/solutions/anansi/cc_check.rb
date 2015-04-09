hash = Hash.new { |hash, key| hash[key] = [] }
   raw_data = [ [1,"American Express"],[1,/^34|^37/], [1, "15"],
                [2,"Diners CLub Blanche"],[2,/^30[0-5]/], [2, "14"],
                [3,"Solo"],[3,/^6334|^6767/],[3,"16"],[3,"18"],[3,"19"]]
   raw_data.each { |x,y| hash[x] << y }

to

check = lambda{|reg,c,*d| if number =~ reg: @company += " or " + c if d.include?(number.length) end }

in a loop. Any idea how to do this?

here the solution:


#!/usr/bin/ruby -w
# validate.rb
######################################################
#         validator for creditcard numbers           #
#                   by anansi                        #
#    29/04/07                      on comp.lang.rub  #
#                                                    #
#        [QUIZ] Checking Credit Cards (#122)         #
######################################################
# recognizes:					     #
#  American Express,				     #
#  Diners CLub Blanche,				     #
#  Diners CLub International,			     #	
#  Diners Club US & Canada,			     #
#  Discover,					     #
#  JCB,						     #
#  Maestro (debit card),			     #
#  Mastercard,					     #		
#  Solo,					     #
#  Switch,					     #	
#  Visa,					     #
#  Visa Electron				     #	
######################################################

 class CreditCard


  def initialize(number)
   number.scan(/\D/) { |x|        # scans number for every not-digit symbol
                        puts x + " is no valid credit card symbol.\nJust digits allowed!!"
                        exit
                        }
  end



  def companycheck(number)
   @company= ""
   # block check compares the length and sets the company value
   check = lambda{|reg,c,*d| if number =~ reg: @company += " or " + c if d.include?(number.length) end }
   #  adding a new bank is quite easy, just put a new check.call in with:
   #  check.call(regular expressions for the starting bytes,"Company-name",length1,length2,...)
   #  I'm sure this can be done somehow better invoking check.call by a loop
   #  but I couldn't figure out how to pass a array with dynamic variable count into check.call
   check.call( /^34|^37/ , "American Express" , 15 )
   check.call( /^30[0-5]/ ,"Diners CLub Blanche",14)
   check.call( /^36/ , "Diners CLub International",14)
   check.call( /^55/ , "Diners Club US & Canada",16)
   check.call( /^6011|^65/ , "Discover",16)
   check.call( /^35/ , "JCB" , 16)
   check.call( /^1800|^2131/ , "JCB" , 15)
   check.call( /^5020|^5038|^6759/ , "Maestro (debit card)" , 16)
   check.call( /^5[0-5]/ , "Mastercard" , 16)
   check.call( /^6334|^6767/ , "Solo" , 16 , 18 , 19)
   check.call( /^4903|^4905|^4911|^4936|^564182|^633110|^6333|^6759/ , "Switch" , 16 , 18 , 19)
   check.call( /^4/ , "Visa" , 13 , 16)
   check.call( /^417500|^4917|^4913/ , "Visa Electron" , 16)
   if @company == ""
     puts "Company   : Unknown"
    else
     puts "Company   : #{@company.slice(4..@company.length)}"
   end
  end



  def crossfoot(digit)
   digit = "%2d" % digit                              # converts integer to string
   if digit[0] == 32
    digit = (digit[1].to_i) -48
   else                                               # if the doubled digit has more than 2 digits
   digit= (digit[0].to_i) + (digit[1].to_i) -96       # adds the single digits and converts back to integer
   end
  end

  def validation(number)
   math = lambda { |dig| number[@count-dig]-48 }  # block math converts str to int of the current digit
   @duplex = false
   @count = number.length
   @result = 0
   for i in (1..@count)
    if @duplex == false              # for every first digit from the back
     @result += math.call i          # add to result
     @duplex = true
    else                                   # for every second digit from the back
     @result += crossfoot((math.call i)*2) # mutl. digit with 2, do the crossfoot and add to result
     @duplex = false
    end
   end
   @result.modulo(10)
  end


 end


#### begin

 if ARGV.length == 0                      # checks if argument is passed
  puts "no input\nusage, e.g.: ruby validate.rb 4408 0412 3456 7893"
  exit
 end


 number = ARGV.join('').gsub(" ","")      # reads args and kills all spaces and newlinefeed

 my_creditcard = CreditCard.new(number)   # checks if just digits are inputed otherwise: abort.

 my_creditcard.companycheck(number)       # checks for known or unknown company

 if my_creditcard.validation(number) == 0 # checks validation with luhn-algo
  puts "Validation: successful"
 else
  puts "Validation: failure"
 end

### eof
