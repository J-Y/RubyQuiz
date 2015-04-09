#!/usr/bin/env ruby
n = ARGV[0].to_i
# Centre text t with spaces to width w
def ct(t,w) u=t.length;r=w-(l=w/2-u/2)-u;' '*l+t+' '*r end
# Factorial
def f(n) n==0?1:n*f(n-1) end
# String value of triangle at row r, column c, using binomial coefficient
def v(r,c) (f(r)/f(c)/f(r-c)).to_s end
# Width of largest value
d=v(n-1,n/2).length
# Width of last line
w=n*d+n-1
# Triangle
n.times{|y|puts(ct((0..y).map{|x|ct(v(y,x),d)}*' ',w))}
