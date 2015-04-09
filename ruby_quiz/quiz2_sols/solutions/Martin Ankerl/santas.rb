# This implementation is heavily optimized to be as fast to 
# implement as possible. Please read the above sentence very
# carefull ;-) I have tried to find an implementation
# that is as simple to understand as possible, but does work.
require 'net/smtp'

Person = Struct.new("Person", :firstName, :familyName, :email)

# extract people from input stream
def readSantas(io)
   santas = Array.new
   io.read.scan(/(\S*)\s(\S*)\s\<(\S*)\>/) do |first, family, email|
      santas.push Person.new(first, family, email)
   end
   santas
end

# get an ordering where each santa gets a person who is 
# outside his family. This implementation is extremely simple,
# as it assumes it is always possible to find a correct solution.
# Actally it is so simple that it hurts. I would never use this
# in production-level code.
def orderPeople(santas)
   isCorrectlyOrdered = false
   while !isCorrectlyOrdered
      # get a random order
      people = santas.sort_by { rand }

      # check if the random order does meet the requirements
      i = 0
      i += 1 while i<santas.size &&
santas[i].familyName==people[i].familyName
      isCorrectlyOrdered = i<santas.size
   end
   people
end

# send santa a mail that he/she is responsible for person's presents
def sendMail(santa, person)
   msg = ["Subject: Santa news", "\n", 
      "You are santa for #{person.firstName} #{person.familyName}" ]

   Net::SMTP.start("localhost") do |smtp|
      smtp.sendmail(msg, "santa delegator", santa.email)
   end
end

if __FILE__ == $0 
   santas = readSantas(STDIN)
   people = orderPeople(santas)

   santas.each_index do |i|
      santa = santas[i]
      person = people[i]
      puts "'#{santa.firstName} #{santa.familyName}' is santa for
'#{person.firstName} #{person.familyName}'"
      # if you really want to send mails, uncomment the following
line.
      #sendMail(santa, person)
   end
end
