#!/usr/bin/env ruby

Person = Struct.new( :first, :last, :email )

# Parses one line and extract the data items
def parse_name( name )
  person = Person.new( *name.split[0..2] )
  if person.first.nil? || person.last.nil? || person.email.nil?
    puts "Invalid input: #{name.inspect}"
    exit
  end
  return person
end

# Reads lines from the given IO object and returns a Hash with all persons as keys
def parse_names( io )
  list = {}
  list[parse_name( STDIN.readline )] = nil until io.eof
  return list
end

# Associates each person with a list of possibile Santas
def build_santa_lists( list )
  list.each_key do |person|
    possible_santas = list.keys
    possible_santas.reject! { |other_person| other_person.last == person.last }
    list[person] = possible_santas
  end
end

# A Santa is correct if there is no other person for whom only the selected Santa is left
def verify_santa( list, person, santa )
  list.each do |key, value|
    return false if key != person && value == [santa]
  end
  return true
end

# Choose a Santa for each person
def choose_santas( list )
  list.each do |person, possible_santas|
    begin santa = possible_santas[rand( possible_santas.length )] end until verify_santa( list, person, santa )
    list.each_value { |value| value.delete( santa ) if Array === value }
    list[person] = santa
  end
end

# Mail the Santas which person they have got
def mail_santas( list )
  list.each do |person, santa|
    santa = Person.new('<no valid santa found>', '', '') if santa.nil?
    puts "Santa #{santa.first} #{santa.last} #{santa.email} for #{person.first} #{person.last} #{person.email}"
  end
end

list = parse_names( STDIN )
build_santa_lists list
choose_santas list
mail_santas list
