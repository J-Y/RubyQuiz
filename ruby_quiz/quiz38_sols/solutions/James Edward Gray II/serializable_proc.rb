#!/usr/local/bin/ruby -w

require "pstore"
require "yaml"

class SerializableProc
	def self._load( proc_string )
		new(proc_string)
	end

	def initialize( proc_string )
		@code = proc_string
		@proc = nil
	end
	
	def _dump( depth )
		@code
	end
	
	def method_missing( method, *args )
		if to_proc.respond_to? method
			@proc.send(method, *args)
		else
			super
		end
	end
	
	def to_proc(  )
		return @proc unless @proc.nil?
		
		if @code =~ /\A\s*(?:lambda|proc)(?:\s*\{|\s+do).*(?:\}|end)\s*\Z/
			@proc = eval @code
		elsif @code =~ /\A\s*(?:\{|do).*(?:\}|end)\s*\Z/
			@proc = eval "lambda #{@code}"
		else
			@proc = eval "lambda { #{@code} }"
		end
	end
	
	def to_yaml(  )
		@proc = nil
		super
	end
end

code = SerializableProc.new(%q{puts "Executing code..."})

File.open("proc.marshalled", "w") { |file| Marshal.dump(code, file) }
code = File.open("proc.marshalled") { |file| Marshal.load(file) }

code.call

store = PStore.new("proc.pstore")
store.transaction do
	store["proc"] = code
end
store.transaction do
	code = store["proc"]
end

code.call

File.open("proc.yaml", "w") { |file| YAML.dump(code, file) }
code = File.open("proc.yaml") { |file| YAML.load(file) }

code.call
