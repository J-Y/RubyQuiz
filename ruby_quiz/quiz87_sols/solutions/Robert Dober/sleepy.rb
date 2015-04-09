#!/usr/bin/ruby

require 'thread'

class IllegalMonitorState < RuntimeError ; end

class BusyFlag # taken from Scott Oak's and Henry Wong's "Java Threads"
	# allows to be called again for a Thread
	# already in possession of the Flag
	def initialize
		@count     = 0
		@possessor = nil
		@mutex     = Mutex.new
		@cv        = ConditionVariable.new
	end
	
	def get
		@mutex.synchronize do
			while not try_get do
				@cv.wait( @mutex )
			end
		end
	end

	def free
		@mutex.synchronize do
			return unless possessing?
			@count -= 1
			return unless @count.zero?
			@possessor = nil
			@cv.signal
		end
	end	
	
	private
	def possessing?
		Thread.current == @possessor
	end
	
	def try_get
		if @possessor.nil? then
			@possessor = Thread.current
			@count = 1
			return true
		end
		return false unless possessing?
		@count += 1
		true
	end
	
end


class Thread
	### keep track if there is a thread in insomnia by means of a supervisor
	### control the insomnia with a supervisor
	@@supervisor = nil
	### time the supervisor slept
	@@time       = 0
	### keep track of the maximum prioriy
	@@max_prio = Thread.current.priority + 1
	### synchronizing management data
	@@lock = BusyFlag.new
	
	alias_method :orig_priority=, :priority=
	def priority= np
		# I do not think this needs to be protected, if a thread is interrupted while setting the priority
		# it cannot yet run with that priority and well not interfere with the insomnia process.
		@@max_prio = np if np > @@max_prio
		self.orig_priority = np
	end
	
	class << self
		
		alias_method :orig_stop, :stop
		
		def insomnia?; @@supervisor end
		def max_prio; @@max_prio end
		def last_time; @@time end
		
		def lock; @@lock; end
		
		def set_insomnia n
			synchronize do
				old_prio = Thread.current.priority
				Thread.current.orig_priority = @@max_prio + 1
				@@supervisor = Thread.new( Thread.current ) { 
					|t|
					Thread.current.orig_priority = @@max_prio + 2
					@@time = orig_sleep n
					t.orig_priority = old_prio
				}
				@@supervisor = nil
			end
		end
		
		def stop_insomnia
			@@supervisor.run if @@supervisor
		end
		
		def stop
			synchronize do
				stop_insomnia
				orig_stop
				@@time
			end
		end
		
		def synchronize( &block )
			begin
				@@lock.get
				block.call
			ensure
				@@lock.free
			end
		end
	end
end

module Kernel
	alias_method :orig_sleep, :sleep
	
	def sleep n
		Thread.synchronize do
			if n < 0 then
				raise IllegalMonitorState, "Already in insommnia mode" if Thread.insomnia?
				return Thread.set_insomnia( -n )
			end
			Thread.lock.free
			### if we are in Thread insomnia we might be interrupted by the supervisor which gets us out of it
			### but even if we call Thread.stop_insomnia then that has no effect. So no sync needed :)
			Thread.stop_insomnia if Thread.insomnia?
			orig_sleep n
		end		
	end
end			