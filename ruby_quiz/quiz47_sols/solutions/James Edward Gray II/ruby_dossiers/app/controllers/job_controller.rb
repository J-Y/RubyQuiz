class JobController < ApplicationController
	before_filter :login_required, :except => [:index, :list, :show]
	before_filter :login_optional, :only => [:show]
	
	def index
		list
		render :action => "list"
	end

	def list
		@job_pages, @jobs = paginate :jobs, :per_page => 10,
		                                    :order_by => "created_on DESC"
	end

	def show
		@job = Job.find(params[:id])
	end

	def new
		@job = Job.new
	end

	def create
		@job           = Job.new(params[:job])
		@job.person_id = @person.id
		@job.state     = params[:other_state] if @job.state == "Other"
		if @job.save
			flash[:notice] = "Job was successfully created."
			redirect_to :action => "list"
		else
			render :action => "new"
		end
	end

	def edit
		@job = Job.find(params[:id])
	end

	def update
		@job = Job.find(params[:id])
		if @job.update_attributes(params[:job])
			flash[:notice] = "Job was successfully updated."
			redirect_to :action => "show", :id => @job
		else
			render :action => "edit"
		end
	end

	def destroy
		Job.find(params[:id]).destroy
		redirect_to :action => "list"
	end
end
