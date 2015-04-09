require "sleep1"

puts "Test 1"

c = Comp.new { |t| sleep 1; puts "#{t} :: Foo here" } <<
    Sleep.new(-1) <<
    Comp.new { |t| puts "#{t} :: Bar there" } <<
    Sleep.new(1) <<
    Comp.new { |t| puts "#{t} :: Well ..." } <<
    Comp.new { |t| puts "#{t} :: Why not" } <<
    Sleep.new(-2) <<
    Comp.new { |t| puts "#{t} :: Just another test" } <<
    Sleep.new(2.5) <<
    Comp.new { |t| puts "#{t} :: A last one ?" }
c.run

puts "Test 2"

c = Comp.new { |t| sleep 1; puts "#{t} :: Foo here" } <<
    Sleep.new(-1) <<
    Comp.new { |t| puts "#{t} :: Bar there" } <<
    Sleep.new(2) <<
    Comp.new { |t| puts "#{t} :: Well ..." } <<
    Comp.new { |t| puts "#{t} :: Why not" } <<
    Sleep.new(-3) <<
    Comp.new { |t| puts "#{t} :: Just another test" }
c.run

puts "Test 3"

c = Comp.new(10) { |t| sleep 1; puts "#{t} :: Foo here" } <<
    Sleep.new(-1) <<
    lambda { |t| puts "#{t} :: Bar there" } <<
    ( Sleep.new(2) <<
    Comp.new { |t| puts "#{t} :: Well ..." } <<
    Comp.new { |t| puts "#{t} :: Why not" } <<
    Sleep.new(-3) <<
    Comp.new { |t| puts "#{t} :: Just another test" } ) <<
    Sleep.new(1.5) <<
    Comp.new { |t| puts "#{t} :: A last one ?" }
c.run
