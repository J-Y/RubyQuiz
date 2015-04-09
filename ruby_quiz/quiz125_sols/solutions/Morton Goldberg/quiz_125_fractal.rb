#  Created by Morton Goldberg on May 26, 2007.
#  quiz_125_fractal.rb

def fractal(n, s)
   if n == 0
      forward s
   else
      fractal(n-1, s/3.0)
      left 90
      fractal(n-1, s/3.0)
      right 90
      fractal(n-1, s/3.0)
      right 90
      fractal(n-1, s/3.0)
      left 90
      fractal(n-1, s/3.0)
   end
end

USAGE = <<MSG
Usage:  turtle_viewer.rb quiz_125_fractal.rb [level]
\twhere level is a single digit integer
\trecommend level be less than 6
MSG

n = case ARGV[0]
    when nil then 3 # show level 3 if no argument given
    when /^\d$/ then ARGV[0].to_i
    else
       puts USAGE
       exit
    end
go [-190, -100]
right 90
pen_down
fractal(n, 380)
