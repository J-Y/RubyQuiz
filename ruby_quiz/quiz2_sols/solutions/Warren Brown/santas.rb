# Required libraries
require 'net/smtp'


# Configuration settings
NO_FAMILIES     = true
NO_TRADES       = true
DISPLAY_RESULTS = true
SEND_EMAILS     = true
SMTP_SERVER     = 'yoursmtpserver.yourisp.com'
FROM_EMAIL      = 'yourfromemail@yourisp.com'
OVERRIDE_EMAIL  = 'youremail@yourisp.com'  # nil to turn off
EMAIL_BODY = %{%{\
From: "Secret Santa Club" <\#{FROM_EMAIL}>
To: "\#{person.santa}" <\#{person.santa.email}>
Subject: Secret Santa

\#{person.santa.first_name},

You are Secret Santa for \#{person}.
You can email \#{person.first_name} at: mailto:\#{person.email}.
}}


# The Person structure
Person = Struct.new('Person',:first_name,:last_name,:email,:santa)
class Person; def to_s; "#{first_name} #{last_name}"; end; end


# Read people into array
people = []
while line = gets
  first_name,last_name,email = line.scan(/(.*) (.*) <(.*)>/).flatten
  people << Person.new(first_name,last_name,email,nil)
end

# Make sure a solution is possible
if people.length < (NO_TRADES ? 3 : 2)
  puts "No solution possible.  Not enough people."
  exit(-1)
end
family = Hash.new(0)
people.each { |person| family[person.last_name] += 1 }
biggest_family = family.max { |a,b| a[1] <=> b[1] }
if biggest_family[1] > people.length / 2
  puts "No solution possible.  Family #{biggest_family[0]} is more than
half" + 
       " of the group (#{biggest_family[1]} out of #{people.length})."
  exit(-1)
end

# Assign each person a random secret santa
pool = people.dup
people.each { |person| person.santa = pool.delete_at(rand(pool.length))
}

# For each person who has an illegal santa, switch with someone else
# Keep looping until no more illegal santas are found
begin
  finished = true
  people.each do |person|
    if (person.santa == person) ||
        (NO_FAMILIES && person.last_name == person.santa.last_name) ||
        (NO_TRADES && person.santa.santa == person)
      finished = false
      new_person = people[rand(people.length)]
      person.santa,new_person.santa = new_person.santa,person.santa
    end
  end
end until finished

# Output results
people.each do |person|
  if DISPLAY_RESULTS
    puts "#{person.santa} is secret santa for #{person}."
  end
  if SEND_EMAILS
    Net::SMTP.start(SMTP_SERVER) do |smtp|
      response = smtp.sendmail(
        eval(EMAIL_BODY),
        FROM_EMAIL,
        OVERRIDE_EMAIL || person.santa.email
      )
      puts "Sent email to #{person.santa.email}, response =
'#{response.chomp}'"
    end
  end
end
