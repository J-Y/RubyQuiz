#!/usr/bin/ruby

2.upto(7) do | i |
	system "time ./learn.rb -p #{i} corpus/*"
end
