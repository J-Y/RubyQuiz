# (c) Copyright 2007 Florian Aßmann. All Rights Reserved.
#
# Used records are stored at the bottom of this file
# This file is written for the rubyquiz lsrc
#
# see ruby main.rb --help for command line options
#
# Cheers
# Florian

RUBY_BIN = '/usr/bin/env ruby' # change this to run the test suite

module NamePicker
  USE = 'LoneStar RubyConf'
  require 'controller'
end

NamePicker::Controller.new( ARGV ).run

__END__
f3a4bd73a33d098926e537cd4ae88381c8816b63
13b170e5eea5d0cb8c830c7554bd28a42a930f96
