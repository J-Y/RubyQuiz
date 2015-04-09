# Represents a family.
class Family
	attr_reader :name, :members

	def initialize(name)
		@name = name
		@members = []
		@bonus = 0
	end
	
	# Number of people in family.
	def count
		@members.length
	end

	# Give a sorting bonus--a family with
	# the bonus will always appear before
	# any families with the same count but
	# no bonus
	def give_bonus
		@bonus = 0.1
	end

	# The count with sorting bonus included
	def count_with_bonus
		count + @bonus
	end
	
	# Pop the last member off.
	def pop
		@members.pop
	end

	# Compare by count/bonus.
	def <=>(other)
		count_with_bonus <=> other.count_with_bonus
	end
end

class Person
	attr_reader :first_name, :last_name, :email
	
	def initialize(first_name, last_name, email)
		@first_name = first_name
		@last_name = last_name
		@email = email
	end
	
	def to_s
		"#{@first_name} #{@last_name} <#{@email}>"
	end
end

familyTable = Hash.new {|h,k| h[k] = Family.new(k)}

while line = gets
	line =~ /(\w+) (\w+) <(.+)>/
	first, last, email = $1, $2, $3
	
	familyTable[last].members << Person.new(first, last, email)
end

puts
puts "Processing..."

families = familyTable.values
santas = []

while families.length > 0

	families.sort!.reverse!

	if families.first.count == 0
		# nobody is left; we're done
		break
	end
	
	if santas.length == 0
		# for the very first santa, choose someone from
		# the largest family
		santas << families.first.pop
		families.first.give_bonus
	else
		success = false
		
		# find largest family that is not one's own
		families.each do |family|
			if family.name != santas.last.last_name
				santas << family.pop
				success = santas.last
				break
			end
		end
		
		raise "No solution." unless success
	end
end

if santas.length > 0 && santas.first.last_name == santas.last.last_name
	raise "No solution."
end

puts "Success!"
puts

lastSanta = santas.last
santas.each do |santa|
	puts santa.to_s + " => " + lastSanta.to_s
	lastSanta = santa
end
