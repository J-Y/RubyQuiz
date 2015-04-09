#!/usr/bin/ruby -w

require 'enumerator'

p(
 ARGV.
 join( ' ').
 reverse.
 to_enum( :each_byte).
 inject( []){ |a, b| a << (a.last || "") + b.chr}.
 map{ |a| a.reverse}.
 inject( []){ |a, b| a << b.match( /^(.+).*\1/).to_a.pop }.
 flatten.
 compact.
 sort_by{ |a| a.size}.
 last
)
