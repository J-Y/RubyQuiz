# Now, taht was a nice, sorht quiz good for a qucik barek... I knew the
# poerblm came up brfeoe, but I wrote my sotouiln berfoe loknoig at
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/82166.

STDIN.each { |line| puts line.gsub(/\B\w+\B/) { $&.split('').sort_by{rand} } }

# Eojny.
