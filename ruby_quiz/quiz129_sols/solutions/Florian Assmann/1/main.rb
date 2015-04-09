# (c) Copyright 2007 Florian Aßmann. All Rights Reserved.
#
# Used records are stored at the bottom of this file
# This file is written for the rubyquiz lsrc
#
# see ruby main.rb --help for command line options
#
# Cheers
# Florian


require 'csv'
require 'optparse'
require 'data_source'

# Defaults...
action = :pick
pick = 1
@from = 'list.csv'

# Parse the args...
OptionParser.new do |o|
  o.banner = "Usage: #{ __FILE__ } [options]" +
  " (default: --pick #{ pick } --from #{ @from })"
  o.separator ''
  o.separator 'Options:'

  o.on( '--list [COLLECTION]', [ :all, :rich, :poor ],
    'List [all|rich|poor]' ) do |name_of_list|
      action = case name_of_list
      when :rich then :list_rich
      when :poor then :list_poor
      else :list_all
      end
  end
  o.on( '--from file', String, 'Read CSV from file (default: list.csv)' ) do |f|
    @from = f
  end
  o.on( '--pick N', Integer, 'Pick N (default: 1) attendees to win' ) do |n|
    pick = n
  end

  o.on_tail( '--test', 'Run tests' ) do
    action = :test
  end
  o.on_tail( '--help', 'Shows this message' ) do
    puts o
    exit
  end
end.parse!

# My dirty little Helpers
def pp attendee
  puts
  attendee.each_key { |key| puts "#{ key }: #{ attendee[ key ] }" }
end
def ds
  @ds ||= begin
    __ds = DataSource.new CSV.readlines( @from )
    if __ds.nil?
      puts "Source file #{ @from } should be readable CSV."
      exit 1
    end
    __ds

  rescue Errno::ENOENT
    puts "Source file #{ @from } couldn't be read, see --help."
    exit 1

  end
end
def recieved? winner
  pp winner
  winner.instance_of? Hash
end
public :recieved?

# Do the action...
if :pick == action
  begin
    ( 1 .. pick ).each { |i| ds.pick_for self }

  rescue IndexError
    puts 'All attendees have won...'

  end

elsif :test == action
# disabled...
#  require 'data_source__test'
  exit

else
  case action
  when :list_rich then ds.winners
  when :list_poor then ds.loosers
  else
    ( ds.winners + ds.loosers )
  end.each { |attendee| pp attendee }
end

puts

__END__
