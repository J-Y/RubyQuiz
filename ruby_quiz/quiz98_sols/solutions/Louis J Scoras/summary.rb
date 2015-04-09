##############################################################################
# summary.rb - Just prints the results

# This didn't need it's own file, but it's not interesting and I'm
# trying to keep the interesting bits near the top of the email =)

def summary(path)
 cost = 0
 back = [nil, 'across the plains', 'through the woods', 'over the moutain']

 path.each_with_index do |n,i|
   cost += n.cost
   puts case i
     when 0
       "Starting at #{n}"
     when path.size - 1
       "and to Grandmothers house #{n} we go!"
     else
       "#{back[n.cost]} to #{n}"
   end
 end
 puts "Found path. Total cost: #{cost}"
end

