class Job < ActiveRecord::Base
	belongs_to :person
	
	ON_SITE_CHOICES = %w{none some all}
	TERMS_CHOICES   = %w{contract hourly salaried}
	STATE_CHOICES   = %w{ Alabama Alaska Arizona Arkansas California Colorado
	                      Connecticut Delaware Florida Georgia Hawaii Idaho
	                      Illinois Indiana Iowa Kansas Kentucky Louisiana Maine
	                      Maryland Massachusetts Michigan Minnesota Mississippi
	                      Missouri Montana Nebraska Nevada New\ Hampshire
	                      New\ Jersey New\ Mexico New\ York North\ Carolina
	                      North\ Dakota Ohio Oklahoma Oregon Pennsylvania
	                      Rhode\ Island South\ Carolina South\ Dakota Tennessee
	                      Texas Utah Vermont Virginia Washington West\ Virginia
	                      Wisconsin Wyoming Other }
	
	validates_inclusion_of :on_site, :in => ON_SITE_CHOICES
	
	validates_inclusion_of :terms, :in => TERMS_CHOICES
	
	validates_presence_of :company, :on_site, :terms, :country, :state, :city, 
	                      :pay, :hours, :description, :required_skills,
	                      :how_to_apply, :person_id
	
	def location
		"#{city}, #{state} (#{country})"
	end
end
