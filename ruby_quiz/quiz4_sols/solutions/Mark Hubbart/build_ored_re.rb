def Regexp.build(*args)
  # splat ranges into arrays of numbers, convert to integers,
  # remove duplicates, and sort the list
  numbers = args.map{|n| [*n] }.flatten.map{|n| n.to_i }
  # create a range from the list of numbers
  /^0*(?:#{numbers.uniq.join("|")})$/
end
