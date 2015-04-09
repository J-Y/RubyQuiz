class PersonMailer < ActionMailer::Base
	def confirm( person, sent_at = Time.now )
		@subject       = "Sign-up Confirmation"
		@recipients    = person.email
		@from          = "confirmation@rubydossiers.com"
		@sent_on       = sent_at
		@body[:person] = person
	end
end
