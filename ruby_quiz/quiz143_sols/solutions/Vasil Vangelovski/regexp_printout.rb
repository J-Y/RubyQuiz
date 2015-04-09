#!/usr/bin/env ruby
#
#-------------------------------------------------------
#
# A very simple and extremely inefficient solution
# for Ruby Quiz #143
#
#-------------------------------------------------------
#  Created by Vasil Vangelovski on 2007-10-14.
#  Copyright (c) 2007. All rights reserved.

class String
  MIN =32
  MAX=126
  #incrementing in base 128, funny characters are skipped
  def increment
    new_one = self
    (new_one.size-1).downto(0) do |index|
      if new_one[index].to_i < MAX
        new_one[index]=(new_one[index].to_i + 1).chr
        return new_one
      end
      if (new_one[index].to_i == MAX)
        new_one[index]=MIN.chr
      end
    end
    return  MIN.chr.to_s  + self
  end
end

class Regexp
  #better to use this method for testing
  def printout(maxlength=5)
    stringus = " "
    while stringus.size <= maxlength
      puts stringus if (self.match(stringus) != nil)
      stringus = stringus.increment
    end
  end
end

/abe|cde|dfg/.printout(3)
