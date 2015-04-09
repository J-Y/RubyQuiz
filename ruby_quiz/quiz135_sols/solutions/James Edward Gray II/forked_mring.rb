#!/usr/bin/env ruby -wKU

unless ARGV.size == 2
  abort "Usage:  #{File.basename($PROGRAM_NAME)} PROCESSES CYCLES"
end
processes, cycles = ARGV.map { |n| n.to_i }

parent, child                = true, false
parent_reader, parent_writer = IO.pipe
reader,        writer        = IO.pipe
my_reader                    = parent_reader

puts "Creating #{processes} processes..."
processes.times do |process|
  if fork
    break
  else
    parent_reader.close unless parent_reader.closed?
    writer.close
    
    parent         = false
    my_reader      = reader
    reader, writer = IO.pipe
  end
  child = true if process == processes - 1
end
if child
  puts "Done."
  my_writer = parent_writer
else
  parent_writer.close
  my_writer = writer
end

if parent
  puts "Timer started."
  start_time = Time.now
  puts "Sending a message around the ring #{cycles} times..."
  cycles.times do
    my_writer.puts "0 Ring message"
    my_writer.flush
    raise "Failure" unless my_reader.gets =~ /\A#{processes} Ring message\Z/
  end
  puts "Done:  success."
  puts "Time in seconds:  #{(Time.now - start_time).to_i}"
else
  my_reader.each do |message|
    if message =~ /\A(\d+)\s+(.+)/
      my_writer.puts "#{$1.to_i + 1} #{$2}"
      my_writer.flush
    end
  end
end
