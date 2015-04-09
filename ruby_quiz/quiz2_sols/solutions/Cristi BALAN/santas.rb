#####################

#!ruby
# evilchelu@irc
# mental@gmail

def generate_input(persons=10, families=3)
	fams = Array.new(families) {|i| 1}
	srand Time.now.to_i
	(persons-families).times do
		fams[rand(families)] += 1
	end
	s = ''
	fams.each_with_index do |fam, famnr|
		fam.times do |i|
			s += (97+i).chr + ' ' + (90-famnr).chr + ' ' + '<' + (97+i).chr +
'@' +  (90-famnr).chr + ".fam>\n"
		end
	end
	return s.sort_by {rand}
end

class Object
	def deep_clone
		Marshal::load(Marshal.dump(self))
	end
end

class Families < Array
	def sum_persons
		s = 0
		self.each { |el| s+= el.persons.size}
		return s
	end
	def get_person(exceptfamily='')
		self.find_all{ |fam| fam.name != exceptfamily
}.sort.reverse.first.persons.shift
	end
end

class Family
	include Comparable
	attr_accessor :name, :persons
	def initialize(name)
		@name = name
		@persons = Array.new
	end
	def to_s
		s = "Family: #{@name}\n"
		persons.each {|p| s+= "  " + p.to_s + "\n"}
		return s
	end
	def <=>(other)
		persons.size <=> other.persons.size
	end
end

class Person
	include Comparable
	attr_accessor :name, :family, :email
	def initialize(args)
		@name = args[0]
		@family = args[1]
		@email = args[2]
	end
	def to_s
		return [@name, @family, @email].join(" ").strip
	end
	def <=>(other)
		tmp = family <=> other.family
		tmp = name <=> other.name if tmp == 0
		return tmp
	end
end

def read_data(input)
	puts "Input\n#{input}\n"
	fams = Families.new
	persons = Families.new
	input.each do |line|
		persons.push Person.new(line.split(/\s/, 3))
		fam = fams.find { |fam| fam.name == persons.last.family}
		if fam.nil?
			fam = Family.new(persons.last.family)
			fams.push fam
		end
		fam.persons.push persons.last unless fam.persons.find{ |pers|
pers.name == persons.last.name}
	end
	return fams
end

def make_santas(fams)
	fams = fams.sort.reverse
	
	santas = fams.deep_clone
	santees = fams.deep_clone
	s = "List of santas (SANTA - SANTEE)\n"
	while santas.sum_persons > 0
		begin
			santa = santas.get_person
			santee = santees.get_person(santa.family)
		rescue
		end
		if (!santa || !santee)
			puts "Bad input. Red Sleigh Down"
			return
		end
		s += santa.to_s + ' - ' + santee.to_s + "\n"
	end
	puts s
end

make_santas(read_data(generate_input()))

#####################
