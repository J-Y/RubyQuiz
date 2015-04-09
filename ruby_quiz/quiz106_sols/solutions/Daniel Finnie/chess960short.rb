#! /usr/bin/ruby
require 'arrayvalue.rb'

KeRN = <<-END.split("\n").collect{|x| x.split(" ")}
	N N R K R
	N R N K R
	N R K N R
	N R K R N
	R N N K R
	R N K N R
	R N K R N
	R K N N R
	R K N R N
	R K R N N
	END

id = ARGV[0].to_i % 960
out = Array.new(8)
1.downto(0) {|x| out[id % 4 *2 + x] = "B"; id /= 4 }
out.to_av.select{|x| x.nil?}[id % 6].set("Q"); id /= 6
KeRN[id].each{ |currentPiece| out.to_av.select{|x| x.nil?}.first.set(currentPiece) }
puts out.join