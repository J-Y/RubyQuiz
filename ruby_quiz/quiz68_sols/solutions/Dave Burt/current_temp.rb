#!/usr/bin/ruby
#
# Current Weather
#
# A response to Ruby Quiz #68 [ruby-talk:181420]
#
# This script basically turns your Ruby device into a weather machine. It
# leverages the latest technology to enable most laptops, PDAs, etc. to capture
# meterorological metrics.
#
# WARNING: this program has a bug resulting in an infinite loop on non-portable
# platforms.
#
# Please ONLY EXECUTE THIS PROGRAM ON PORTABLE DEVICES.
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 23 Oct 2005
#

require 'highline/import'

# Work around bug
agree("Are you using a portable Ruby device? ") or
    abort("Sorry, this program has not yet been ported to your platform.")

# Calibrate instrumentation
begin
    say "Go outside."
end until agree("Are you outside now? ")

# Ascertain cloud cover
if agree("Is your Ruby device casting a defined shadow? ")
    say "It's sunny."
else
    say "It's overcast."
end

# Capture rainfall
if agree("Are your Ruby device or your umbrella wet? ")
    say "It's raining."
else
    say "It's fine."
end

# Weigh other precipitation
if agree("Is your Ruby device becoming white? ")
    say "It's snowing."
else
    say "It's not snowing."
end

# Discern current temperature
if agree("Are your fingers getting cold? ")
    say "It's cold."
else
    say "It's warm."
end

# Measure wind speed
if agree("Do you feel lateral forces on your Ruby device? ")
    say "It's windy."
else
    say "It's calm."
end

say "This weather report has been brought to you by Ruby, the letter D,"
say "and the number 42."
