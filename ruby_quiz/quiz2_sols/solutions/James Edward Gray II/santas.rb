#!/usr/bin/env ruby

require "net/smtp"

unless ARGV.size == 1
	puts "Usage:  #{$0} SMTP_SERVER\n"
	exit
end

$players = STDIN.readlines.map { |line| line.chomp }
$santas = $players.sort_by { rand }

def check_families?
	$players.each_with_index do |who, i|
		return false if who[/\S+ </] == $santas[i][/\S+ </]
	end
	return true
end

$santas = $players.sort_by { rand } until check_families?

Net::SMTP.start(ARGV[0]) do |server|
	$santas.each_with_index do |santa, i|
		message = <<END_OF_MESSAGE
From:  Secret Santa Script <james@grayproductions.net>
To:  #{santa}
Subject:  Secret Santa Pick

#{santa[/\S+/]}:

You have been chosen as the Secret Santa for #{$players[i]}.  Merry Christmas.

Secret Santa Selection Script (by James)
END_OF_MESSAGE
		begin
			server.send_message(
					message,
					"james@grayproductions.net",
					santa[(santa.index("<") + 1)...santa.index(">")] )
		rescue
			puts "A message could not be sent to #{santa}.\n#{$!}"
		end
	end
end
