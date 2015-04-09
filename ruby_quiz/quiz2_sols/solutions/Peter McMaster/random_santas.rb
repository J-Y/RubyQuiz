#!/usr/bin/env ruby

class Person
  attr_reader :sname, :email
  def initialize(details)
    @fname, @sname, @email = details.scan(/(\w+)\s+(\w+)\s+<(.*)>/)[0]
  end
  def to_s() @fname + " " + @sname end
end

a, b = [], []

STDIN.each do |l|
  someone = Person.new(l)
  a << someone;  b << someone
end

puts "Mixing..."

passes = 0
begin
  ok = true
  a.each_index do |idx|
    passes += 1
    if a[idx].sname == b[idx].sname
      ok = false
      r = rand(b.length); b[idx], b[r] = b[r], b[idx]
    end
  end
end until ok

a.each_index { |idx| puts "#{a[idx]} is santa'd with #{b[idx]}" }

puts "[#{passes} passes required.]"
