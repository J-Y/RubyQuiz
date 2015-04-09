#! /usr/bin/ruby
#
############### Pascal Triangle by Eric DUMINIL ###############
#   
# This program is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any
# later version.
# 
# How-to use it?
#       pascal.rb height excentricity
# with:      
#   height, pretty self-explanatory
#   excentricity, float between -1 and 1.
#   
#               height set to 5 and excentricity set to -1:
#                          
#               1
#               1 1
#               1 2 1
#               1 3 3 1
#               1 4 6 4 1
#               
#               height set to 5 and excentricity set to 1 :
#              
#                      1
#                    1 1
#                  1 2 1
#                1 3 3 1
#              1 4 6 4 1
#              
#              
#              By default, excentricity is set to 0:      
#              
#                  1
#                 1 1
#                1 2 1
#               1 3 3 1
#              1 4 6 4 1            
#


#Just to make sure we can calculate C(n,n/2)
#without having to build the whole tree
class Fixnum
    def fact
        return 1 if self<2
        self*(self-1).fact
    end

    def cnp(p)
        self.fact/(p.fact*(self-p).fact)
    end
end


class PascalTriangle  
    def initialize (height=15,excentricity=0)
        @height=height
        @excentricity=excentricity
        #maxLength should be odd, so that the alignment is preserved
        @maxLength=(height-1).cnp((height-1)/2).to_s.length|1
        createAndShow
    end

    attr_reader :height, :maxLength, :excentricity

    def createAndShow
        previous=[1]
        current=Array.new
        height.times{|i|
            current[0]=current[i]=1
            #Taking care of the symetry
            1.upto(i/2){|j|
                current[j]=current[i-j]=previous[j]+previous[j-1]   
            }
            puts " "*((maxLength+1)*(excentricity+1)/2)*(height-i-1)+
                 current.map{|number|
                    number.to_s.rjust(maxLength)
                 }.join(" ")
            #No need to remember the whole triangle,
	    #the previous row will be enough
            previous.replace(current)
        }
    end
end

PascalTriangle.new(ARGV[0].to_i,ARGV[1].to_f)

###############################################################################
