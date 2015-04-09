#!/usr/bin/env ruby

if /^(-[?])|(-h)|(-help)|(--help)$/ =~ ARGV[0] || ARGV.length > 1
  $stderr.puts "Usage: #{$PROGRAM_NAME} [filename]"
  exit 1
end

infile = $stdin
if ARGV.length == 1
  infile = File.new(ARGV[0]) rescue begin
    $stderr.puts("File not found: '#{ARGV[0]}'")
    exit 2
  end
end

tok_exp = /([a-zA-Z][a-z]*)|([^A-Za-z]+)/
word_exp = /[a-zA-Z][a-z]{3,}/

infile.each_line { |line| puts line.scan(tok_exp).flatten!.map! { |tok|
    if word_exp =~ tok
      newtok = [tok[0..0]]
      newtok << tok[1...-1].split('').sort_by{rand}
      newtok << tok[-1..-1]
    else
      tok
    end
  }.join
}
