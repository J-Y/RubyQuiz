#!/usr/bin/env ruby
require 'net/smtp'

class Oops < Exception; end

def split_line(line)
  name, surname, email = line.scan(/^(\w+)\s(\w+)\s+<(.+)>$/).flatten
  return name, surname, email
end

def choose_person(name, surname, list)
  person = list.find_all { |n, sn| sn != surname and n != name }.pop
  raise Oops if person.nil?
  list.delete(person)
  return person
end

def split_list(list)
  newlist = []
  list.each { |line| newlist << split_line(line) }
  return newlist
end

def send_mail(to, name, conf)
  msg = <<__EOM__
From: Secret Santa Robot <#{conf[:from]}>
To: #{to}
Subject: Your chosen person

Your chosen person is #{name}.

Best regards,
The Secret Santa Robot
__EOM__

  Net::SMTP.start(conf[:server], 25, conf[:domain], conf[:user],
                  conf[:password], conf[:auth].intern) do |smtp|
    smtp.send_message msg, conf[:from], to
  end
end

#
# Main
#
mailconf = {
  :server   => 'smtp.secretsanta.com',
  :domain   => 'secretsanta.com',
  :from     => 'robot@secretsanta.com',
  :user     => 'robot',
  :password => 'tobor',
  :auth     => 'plain',
}

tries = 1
santas = split_list(ARGF.to_a)

families = {}
santas.each { |name, surname, email|
  families[surname] = families[surname] ? families[surname] + 1 : 1
  if families[surname] > santas.length / 2
    raise "Too many people from the same family."
  end
}

hash = {}
begin
  people = santas.sort_by { rand }
  santas.each { |name, surname, email|
    pname, psname = choose_person(name, surname, people)
    hash[email] = "#{pname} #{psname}"
  }
rescue Oops
  tries += 1
  retry
end

#hash.each { |email, dest| send_mail(email, dest, mailconf) }
hash.each { |email, dest| puts "#{email} -> #{dest}" }
puts "Finished in #{tries} tries."
