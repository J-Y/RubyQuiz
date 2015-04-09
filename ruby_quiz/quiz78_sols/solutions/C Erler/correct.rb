# Repairs any errors.  When repairing, this errs on the side of too much packaging.  To reduce excess packaging, don't have errors.
# It's a bit ugly, but I don't think I let any possible breakages through. If I did, please let me know.
MaxCleanTime = 5
# This has optional damage prevention enhancements.  Uncomment the paragraphs with an "# (option)" header if you want an option.
def clean_diagram packing_diagram, start_time=Time.now.to_i, length=0, best_so_far=[1.0/0.0, nil], recursion_so_far=false
 # If we've already lost, quit.
 return nil if length >= best_so_far.first or Time.now.to_i - start_time > MaxCleanTime

 unless recursion_so_far
   # Do nothing if nothing is being packed.
   return '' unless packing_diagram =~ /B/

   # Make an unfrozen copy of the original.
   packing_diagram = packing_diagram.dup

   # Remove extraneous characters: (**Chunky bacon B ) -> (B)
   packing_diagram.gsub! /[^B\(\)\[\]\{\}]/, ''

   # Remove packing that surrounds no items: (()B) -> (B)
   packing_diagram.gsub! /^[\)\]\}]|[\(\[\{][\)\]\}]|[\(\[\{]$/, '' while packing_diagram =~ /^[\)\]\}]|[\(\[\{][\)\]\}]|[\(\[\{]$/

   # Get the length.
   length = packing_diagram.length

   # Mark items as properly nested.
   packing_diagram.gsub! /B/, 'Bm'
 end

 # Mark all properly nested packaging.
 while packing_diagram =~ /(\(([^m]m)*\)|\[([^m]m)*\]|\{([^m]m)*\})([^m]|$)/
   packing_diagram.gsub! /\(((?:[^m]m)*)\)([^m]|$)/, '(m\1)m\2'
   packing_diagram.gsub! /\[((?:[^m]m)*)\]([^m]|$)/, '[m\1]m\2'
   packing_diagram.gsub! /\{((?:[^m]m)*)\}([^m]|$)/, '{m\1}m\2'
 end

 # If we have improper nesting :
 if packing_diagram !~ /^([^m]m)+$/
   # If we have an opener with an improper closer: (B] :
   if (mismatch = /([\(\[\{])(?:[^m]m)*([\)\]\}])(?:[^m]|$)/.match packing_diagram)
     # Fix improper nestings in two different ways: by duplicating the opening packaging and by duplicating the closing packaging.
     clean_diagram(packing_diagram.dup.insert(mismatch.begin(2), { '(' => ')', '[' => ']', '{' => '}' }[mismatch[1]]), start_time, length + 1, best_so_far, true)
     clean_diagram(packing_diagram.dup.insert(mismatch.begin(1) + 1, { ')' => '(', ']' => '[', '}' => '{' }[mismatch[2]]), start_time, length + 1, best_so_far, true)
     packing_diagram = nil

   # If we have an opener without even an improper closer or vice versa: (B))(B) :
   else
     # If an unmarked opener falls off the right end :
     if (mismatch = /([\(\[\{])(?:[^m]m)*$/.match packing_diagram)
       packing_diagram << { '(' => ')', '[' => ']', '{' => '}' }[mismatch[1]]

     # If an unmarked opener slams into an unmarked opener :
     elsif (mismatch = /([\(\[\{])(?:[^m]m)*([\(\[\{])(?:[^m]|$)/.match packing_diagram)
       packing_diagram.insert(mismatch.begin(2), { '(' => ')', '[' => ']', '{' => '}' }[mismatch[1]])

     # If an unmarked closer falls off the left end :
     elsif (mismatch = /^(?:[^m]m)*([\)\]\}])(?:[^m]|$)/.match packing_diagram)
       packing_diagram.insert(0, { ')' => '(', ']' => '[', '}' => '{' }[mismatch[1]])

     # If an unmarked closer slams into an unmarked closer :
     elsif (mismatch = /([\)\]\}])(?:[^m]m)*([\)\]\}])(?:[^m]|$)/.match packing_diagram)
       packing_diagram.insert(mismatch.begin(1) + 1, { ')' => '(', ']' => '[', '}' => '{' }[mismatch[2]])
     end

     clean_diagram packing_diagram, start_time, length + 1, best_so_far, true
     packing_diagram = nil
   end

 # If we have proper nesting :
 else
   # Remove markings.
   packing_diagram.delete! 'm'

   # (option) Ensure no items are left outside any packaging: B(BBB) -> (B(BBB))
   #~ packing_diagram.sub! /^(B.*|.*B)$/, '(\1)'

   # (option) Ensure no item touches another item: (BBB) -> (B(B)B)
   #~ packing_diagram.gsub! /BB/, 'B(B)' while packing_diagram =~ /BB/

   # (option) Ensure all items are individually wrapped: ((B)B) -> ((B)(B))
   #~ packing_diagram.gsub! /(^|[B\)\]\}])B/, '\1(B)' while packing_diagram =~ /(^|[B\)\]\}])B/
   #~ packing_diagram.gsub! /B([B\(\[\{]|$)/, '(B)\1' while packing_diagram =~ /B([B\(\[\{]|$)/
 end

 # Update best_so_far.
 best_so_far.replace [packing_diagram.length, packing_diagram] if packing_diagram.length < best_so_far.first unless packing_diagram.nil?

 best_so_far.last
end

# Choice two
puts clean_diagram(ARGV.join(' '))
