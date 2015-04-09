#!/usr/bin/ruby

require 'fileutils'
require 'markovtap'

require 'optparse'

class LearnOptions < OptionParser
	attr_reader :max_prefix, :help
	def initialize
		super()
		@help = false
		@basename = 'typedatabase'
		@max_prefix = 6
		self.on("-o", "--output FILENAME", String)  { | v | @filename   = v }
		self.on("-p", "--prefix-length N", Integer) { | v | @max_prefix = v }
		self.on("-?", "--help") { @help = true }
	end

	def filename() @filename || "#{@basename}.#{@max_prefix}"	end
end

options = LearnOptions.new
begin
	options.parse!(ARGV)
rescue => e
	puts e
	puts options
	exit
end

if options.help
	puts options
	exit
end

$stderr.puts "Loading database"

md = if File.exist?(options.filename)
			 MarkovDict.load(options.filename)
		 else
			 MarkovDict.new(options.max_prefix)
		 end
md.database_file = options.filename

$stderr.puts "Learning"
md.learn(ARGF)

$stderr.puts "Saving"
md.save()
