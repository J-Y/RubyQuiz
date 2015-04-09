#!/usr/bin/env ruby
# = Ruby Quiz 129: LSRC Name Picker
#   Author: Jesse Merriman
#
# == Usage
#
# pick.rb [OPTION] [DB-FILE]
#
# -h, --help:
#   Print out usage message.
#
# -a, --add-names:
#   Take a list of names on standard input and add them to the DB. Creates the
#   DB if it does not exist.
#
# -l, --list-names:
#   List out all names in the DB to standard output, if it exists.
#
# -c, --clear-names:
#   Clear the DB of all names, if it exists.
#
# -p, --pick-simple
#   Randomly choose an unchosen name from the DB, if it exists.
#
# -f, --pick-fancy
#   Like --pick, but display the chosen name in a fancy way.
#
# -s, --save-fancy FILENAME
#   Like --pick-fancy, but save the graphic to FILENAME instead of displaying.
#   Very SLOW.
#
# -d, --destroy-db:
#   Destroy the DB, if it exists.
#
# If no option is given, the default is --add-names if no DB exists, or
# --pick-fancy if it does.
#
# DB-FILE defaults to 'names.db'.

require 'pickerface'
require 'getoptlong'
require 'rdoc/usage'

if __FILE__ == $0
  Opts = GetoptLong.new(
    [ '--help',        '-h', GetoptLong::NO_ARGUMENT ],
    [ '--add-names',   '-a', GetoptLong::NO_ARGUMENT ],
    [ '--list-names',  '-l', GetoptLong::NO_ARGUMENT ],
    [ '--clear-names', '-c', GetoptLong::NO_ARGUMENT ],
    [ '--pick-simple', '-p', GetoptLong::NO_ARGUMENT ],
    [ '--pick-fancy',  '-f', GetoptLong::NO_ARGUMENT ],
    [ '--save-fancy',  '-s', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--destroy-db',  '-d', GetoptLong::NO_ARGUMENT ] )

  # Handle arguments.
  op, args = nil, []
  Opts.each do |opt, arg|
    case opt
      when '--help';        RDoc::usage
      when '--add-names';   op = :add_names
      when '--list-names';  op = :list_names
      when '--clear-names'; op = :clear
      when '--pick-simple'; op = :pick_simple
      when '--pick-fancy';  op = :pick_fancy
      when '--save-fancy';  op = :save_fancy; args << arg
      when '--destroy-db';  op = :destroy
    end
  end

  # Setup default arguments.
  ARGV.empty? ? db_file = 'names.db' : db_file = ARGV.first
  if op.nil?
    File.exists?(db_file) ? op = :pick_fancy : op = :add_names
  end

  # Run.
  Pickerface.new(db_file).send(op, *args)
end
