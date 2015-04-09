#!/usr/local/bin/ruby

class Person
	attr_accessor :first_name, :last_name, :email
	@@people_by_email = {}
	def initialize( first_name, last_name, email=nil )
		@first_name = first_name
		@last_name = last_name
		@email = email
		people_with_same_email = @@people_by_email[@email]
		if people_with_same_email
			if people_with_same_email.include? self
				warn "Warning: #{self} was previously initialized with the same values."
			else
				warn "Warning: Email address <#{email}> registered for #{people_with_same_email.join(', ')} and #{self}."
			end
		end
		(@@people_by_email[@email] ||= []) << self unless people_with_same_email && people_with_same_email.include?( self)
	end
	def to_s; %|<Person "#{@first_name} #{@last_name}">|; end
	def full_name
		"#{@first_name} #{last_name}"
	end
	def to_a; [self]; end
	def ==( p )
		@first_name==p.first_name && @last_name==p.last_name && @email==p.email
	end
end

require 'singleton'
class ZecretZanta
	include Singleton

	attr_reader :santa_list

	def initialize
		@list_ready = false
	end
	
	def load_participants
		@santa_list = STDIN.readlines.collect{ |line|
			match = line.match( /^\s*(\w+?)\s*(\w+?)\s*<(.+?)>/ )
			next unless match
			Person.new( match[1], match[2], match[3] )
		}.compact.sort_by{ rand }
	end
	
	# Create 3072 people in the pathological case
	def simulate_participants
		first_names =  %w|Gavin Lisa Dain Baird Danna Don Linden Anika Freya Sonja Joe Mattias James Andre Thomas Ben Florian James Phleep Tessa Adriane Ibberz Ivan Adriane|
		last_names = %w| Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family0 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family1 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family2 Family3 Family3 Family3 Family3 Family3 Family3 Family3 Family3 Family4 Family4 Family4 Family4 Family5 Family5 Family6 Family7 |
		@santa_list = []
		last_names.each_with_index{ |last,i|
			first_names.each_with_index{ |first,j|
				name = "#{first}#{i}#{j}"
				@santa_list << Person.new( name, last, name+'@xafdz.bik' )
			}
		}
		@santa_list.sort_by{ rand }
	end
	
	def randomize_recipients
		raise "No @santa_list to work on" unless @santa_list

		require 'Ouroboros'
		@santa_list = Ouroboros.from_a( @santa_list )
		@santa_list.separate_duplicates_old! { |person| person.last_name }
		@santa_list = @santa_list.to_a
		@list_ready = true
	end
	
	def email_santa_info
		require 'net/smtp'
		
		email_from    = 'north@pole.org'
		email_subject = 'And your secret santa is...'
		
		Net::SMTP.start('localhost', 25){ |smtp|
			@santa_list.each_with_index{ |recipient,i|
				giver = @santa_list[ (i-1) % @santa_list.length ]
				if $DEBUG
					puts "Psst! Hey, #{giver}, your Secret Santa is #{recipient}"
				else
					smtp.ready( email_from, giver.email ) { |msg|
						msg << "To: #{giver.full_name} <#{giver.email}>\r\n"
						msg << "Subject: #{email_subject}\r\n"
						msg << "\r\n"
						msg << <<MESSAGE_END
Your secret santa this year is #{recipient.full_name}.
Go be sneaky!
MESSAGE_END
					}
				end
			}
		}
	end
end

$DEBUG = true

puts "Enter the participants in the format 'FirstName LastName <email>':"
zz = ZecretZanta.instance
#zz.simulate_participants
zz.load_participants
zz.randomize_recipients
zz.email_santa_info
