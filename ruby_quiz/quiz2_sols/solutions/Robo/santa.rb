require 'net/smtp'

#a very smart Hat that even knows how to email
class Hat

  #represents a member of the Christmas gathering
  Member = Struct.new(:firstName, :lastName, :email, :minion)

  def initialize
    @members = []
    @pool = []
  end

  #put a new member into the hat
  def put(firstName, lastName, email)
    member = Member.new(firstName, lastName, email)
    @members << member
    @pool << member
  end

  #match each Secret Santa to a person
  def match
    @members.each do |santa|
      santa.minion = draw(santa)
      notify(santa)
    end
  end

  #draw a person out of the hat for a Secret Santa
  def draw(santa)
    validPool = filter(santa)
    person = validPool.at(rand(validPool.size))
    @pool.delete(person)
  end

  #filter out people who're in the same family as Secret Santa
  def filter(santa)
    @pool.select do |member|
      member.lastName != santa.lastName
    end
  end

  #notify each Secret Santa who they'll be watching over
  def notify(santa)
    if santa.minion != nil
      msg = "#{santa.firstName} #{santa.lastName} is watching over " +
            "#{santa.minion.firstName} #{santa.minion.lastName}"
    else
      msg = "#{santa.firstName} #{santa.lastName} is watching over nobody"
    end

    puts msg

    #Net::SMTP.start('smtp.example.com', 25) do |smtp|
    #  smtp.send_message(msg, 'hat@magic.com', santa.email)
    #end
  end
end

def main
  h = Hat.new
  while (s = gets()) != nil
    s.scan(/^(.*?) (.*?) <(.*?)>$/) do |firstName, lastName, email|
      h.put(firstName, lastName, email)
    end
  end
  h.match
end

if __FILE__ == $0
  main
end
