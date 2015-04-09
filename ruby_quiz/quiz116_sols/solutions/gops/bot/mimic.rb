#!/usr/bin/env ruby -w

13.times do
  $stdout.puts $stdin.gets[/\d+/]
  $stdout.flush
  $stdin.gets # opponent's bid--ignored
end
