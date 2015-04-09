class String
  def unique_permutations
    # modified to get unique permutations
    # from http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/139858
    # which says it was inspired by a RubyQuiz! :)
    return [self] if self.length < 2
    perms = Hash.new

    0.upto(self.length - 1) do |n|
      #rest = self.split('')
      rest = self.split(//u)            # for UTF-8 encoded strings
      picked = rest.delete_at(n)
      rest.join.unique_permutations.each { |x| perms[picked + x] = nil }
    end

    perms.keys
  end
end

digits = ARGV[0]
ops = ARGV[1]
target = ARGV[2].to_i

# pad ops list with spaces to match the number of slots between the digits
ops = ops + " " * (digits.size - ops.size - 1)

# build a format string with slots between the digits
digits = digits.split("").join("%s")


operator_perms = ops.unique_permutations
operator_perms.each do |p|
  # build expression by inserting the ops into the format string,
  # after converting spaces to empty strings
  exp = digits % p.split("").map{|x|x.chomp(" ")}
  val = eval(exp)
  puts "*******************" if val==target
  puts exp + " = " + val.to_s
  puts "*******************" if val==target
end
puts
puts "%d possible equations tested" % operator_perms.size
