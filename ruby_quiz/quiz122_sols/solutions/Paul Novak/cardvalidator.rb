# cardvalidator.rb
#
require 'metaid'

module Card
  @cards=[]

  def Card.Base *u
    c = @cards
    Class.new {
      meta_def(:patterns){u}
      meta_def(:validity){|x|Card.validity(x)}
      meta_def(:inherited){|x|c<<x}
    }
  end
  def Card.validate cardnum
    @cards.map { |k|
      k.patterns.map { |x|
        if cardnum =~ /^#{x}\/?$/
          return [k.name.upcase, k.validity(cardnum)].join( " ")
        end
      }
    }
    raise "Unexpected Card Number pattern:  '#{cardnum}'"
  end
  def Card.sum_of_digits s
    s.split("").inject(0){|sum,x|sum + Integer(x)}
  end
  def Card.luhnSum s
    temp = ""
    r = 0..s.size
    a = s.split("").reverse
    r.each do |i|
      if i%2==1
        x = (Integer(a[i])*2).to_s
      else
        x = a[i]
      end
      temp << x.to_s
    end
    sum_of_digits temp
  end
  def Card.validity cardnum
    if (Card.luhnSum(cardnum) % 10)==0
      return "Valid"
    else
      return "Invalid"
    end
  end
end

# patterns will be tested for match in order defined
class Visa < Card.Base /4[0-9]{12,15}/
end
class Amex < Card.Base /3[4,7][0-9]{13}/
end
class Mastercard < Card.Base /5[1-5][0-9]{13}/
end
class Discover < Card.Base /6011[0-9]{12}/
end
# catch-all
class Unknown < Card.Base /.+/
end

p Card.validate(ARGV[0])
