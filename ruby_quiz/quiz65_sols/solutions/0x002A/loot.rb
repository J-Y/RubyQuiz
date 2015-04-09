=begin
my solution was inspired by a lecture about scheme/lisp streams. the
possible-solution space is searched in a quite stupid manner which
makes it kind of slow... :-)
=end

require 'lazylist'

pirates = ARGV.shift.to_i
loot = ARGV.map {|x| x.to_i}

# this computes _all_ solutions (but does so lazyly)
# also this doesn't check for equivalent solutions, but we don't care
# since only the first solution is computed and printed
LazyList[1 ... pirates**loot.size].map {|owners|
	# owners encodes a way to give each pirate a subset of the loot
	# (as a number of base "pirates")
	bags = Array.new(pirates) {[]}
	idx = loot.size - 1
	begin
		owners, owner = owners.divmod(pirates)
		bags[owner] << loot[idx]
		idx -= 1
	end while owners > 0
	idx.downto(0) do |i|
		bags[0] << loot[i]
	end
	bags
}.map {|splitting|
	# now map to the sums
	puts "computed sums for #{splitting.inspect}"
	[splitting, splitting.map {|pieces| pieces.inject(0) {|s,p| s +
	p}}]
}.select {|splitting, sums|
	# are all sums the same?
	sums.uniq.length == 1
}.map {|splitting, sums|
	# forget the sums
	splitting
}.take.each {|splitting|
	# take the first solution and just output it
	splitting.each_with_index {|pieces, owner|
		puts " #{owner+1}: #{pieces.sort.join(" ")}"
	}
}
