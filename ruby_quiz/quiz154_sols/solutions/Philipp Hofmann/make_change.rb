#!/usr/bin/ruby

# ------------------------------------------------------------
# 1st approach: recursive, short, but slow
#
# def make_change(amount, coins = [25, 10, 5, 1])
# 	return [amount] if coins.include?(amount)
# 	options = {}
# 	coins.select { |c| c < amount }.each { |coin| options[coin] = make_change(amount - coin, coins) }
# 	pick = options.values.sort { |a, b| a.size <=> b.size }.first
# 	([options.index(pick)] + pick).sort.reverse
# end

# ------------------------------------------------------------
# 2nd approach: much faster
# Making use of Daniel Martins's PriorityQueue from Quiz #98

class PriorityQueue

	def initialize
		@list = []
	end

	def add(priority, item)
		@list << [priority, @list.length, item]
		@list.sort!
		self
	end

	def <<(pritem)
		add(*pritem)
	end

	def next
		#puts @list.first.inspect
		@list.shift[2]
	end

	def empty?
		@list.empty?
	end

end

def make_change(amount, coins = [25, 10, 5, 1])
	return [] if amount==0
	pqueue = PriorityQueue.new
	solution = nil
	coins.sort.reverse.each { |coin| pqueue << [0, [coin, [], coin]] if coin <= amount }
	until pqueue.empty?
		coin, change, sum = pqueue.next
		return solution if solution && change.size > solution.size
		change = change + [coin]
		solution = change.sort.reverse if sum==amount
		coins.each do |coin|
			priority = change.size + amount - (sum + coin)
			pqueue << [priority, [coin, change, sum + coin]] if sum + coin <= amount
		end
	end
	nil
end

