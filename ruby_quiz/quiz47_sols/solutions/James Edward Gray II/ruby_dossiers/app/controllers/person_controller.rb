class PersonController < ApplicationController
	layout  "job"

	def login
		if @request.post?
			@person = Person.authenticate( @params[:person][:email],
			                               @params[:person][:password],
			                               @params[:person][:confirmation] )
			if @person
				@session[:person_id] = @person.id
				flash["notice"]      = "Login successful."
				
				redirect_back_or_default :controller => "job", :action => "list"
			elsif @person == false
				flash[:first_login] = true
				@email              = @params[:person_email]
				flash.now["notice"] = "Please enter your confirmation number."
			else
				@email              = @params[:person_email]
				flash.now["notice"] = "Login unsuccessful."
			end
		else
			@person = Person.new
		end
	end
  
	def signup
		@person = Person.new(@params[:person])
		
		if @request.post? and @person.save
			PersonMailer.deliver_confirm(@person)
			
			flash["notice"]     = "Signup successful.  Please login."
			flash[:first_login] = true
			
			redirect_back_or_default :action => :login
		end
	end  
  
	def logout
		@session[:person_id] = nil
	end
end
