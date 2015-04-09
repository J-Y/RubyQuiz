require "digest/sha1"

# 
# This model expects a certain database layout and its based on the 
# name/login pattern.
# 
class Person < ActiveRecord::Base
	has_many :jobs
	
	validates_uniqueness_of :email, :on => :create
	validates_format_of :email,
	                    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/

	validates_confirmation_of :password
	validates_length_of :password, :within => 5..40

	validates_presence_of :full_name, :email, :password

	# 
	# Please change the salt to something else. 
	# Every application should use a different one.
	# 
	@@salt = "dossiers4Ruby"
	cattr_accessor :salt

	# Authenticate a user. 
	#
	# Example:
	#   @person = Person.authenticate("bob@domain.com", "bobpass", RanD02)
	#
	def self.authenticate(email, password, confirmation)
		person = find_first( [ "email = ? AND password = ?",
		                       email, sha1(password) ] )
		return nil if person.nil?
		unless person.confirmation.blank?
			if confirmation == person.confirmation
				person.confirmation = nil
				person.save or raise person.errors.full_messages.join(",")
				person
			else
				false
			end
		end
	end  

	protected

	# 
	# Apply SHA1 encryption to the supplied password. 
	# We will additionally surround the password with a salt 
	# for additional security.
	# 
	def self.sha1(password)
		Digest::SHA1.hexdigest("#{salt}--#{password}--")
	end
    
	before_create :crypt_password
  
	# 
	# Before saving the record to database we will crypt the password 
	# using SHA1. 
	# We never store the actual password in the DB.
	# 
	def crypt_password
		write_attribute "password", self.class.sha1(password)
	end
  
	before_update :crypt_unless_empty
  
	# 
	# If the record is updated we will check if the password is empty.
	# If its empty we assume that the user didn't want to change his
	# password and just reset it to the old value.
	# 
	def crypt_unless_empty
		if password.empty?
			person = self.class.find(self.id)
			self.password = person.password
		else
			write_attribute "password", self.class.sha1(password)
		end
	end
	
	before_create :generate_confirmation
	
	def generate_confirmation
		code_chars = ("A".."Z").to_a + ("a".."z").to_a + (0..9).to_a
		write_attribute "confirmation",
		                Array.new(6) { code_chars[rand(code_chars.size)] }.join
	end
end
