#!/usr/bin/env ruby

$VERBOSE = true

1.upto(100) do |num|

  case  when num.modulo(3) == 0 && num.modulo(5) == 0      :puts 'fizzbuzz'

        when num.modulo(3) == 0                            :puts     'fizz'

        when num.modulo(5) == 0                            :puts     'buzz'

        else                                                puts       num
  end

end
