#!/usr/bin/env ruby

class Person
  attr_reader :sname, :email
  attr_accessor :santa
  def initialize(details)
    @fname, @sname, @email = details.scan(/(\w+)\s+(\w+)\s+<(.*)>/)[0]
  end
  def to_s() @fname + " " + @sname end
  def status()
    if @santa then self.to_s + " is santa'd to " + @santa.to_s
    else self.to_s + " is santa-less!\a" end # Ooh... beeps.
  end
end

families = Hash.new {[]}
unchosen = []

DATA.each do |l|
  someone = Person.new(l)
  families[someone.sname] <<= someone
  unchosen << someone
end

families.keys.each do |sname|
  choices = unchosen.dup.delete_if { |someone| someone.sname == sname }
  families[sname].each do |person|
    person.santa = unchosen.delete(choices.delete_at(rand(choices.length)))
    puts person.status
  end
end

__END__
Luke Skywalker <luke@theforce.net>
Leia Skywalker <leia@therebellion.org>
Toula Portokalos <toula@manhunter.org>
Gus Portokalos <gus@weareallfruit.net>
Bruce Wayne <bruce@imbatman.com>
Virgil Brigman <virgil@rigworkersunion.org>
Lindsey Brigman <lindsey@iseealiens.net>
