#!/usr/local/bin/ruby
# Copyright (c) 2000 Brian Fundakowski Feldman
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $Id: img2ascii.rb,v 1.5 2000/11/01 06:06:14 green Exp green $
#
# Convert an image into greyscale ASCII art.
#
# usage: img2ascii.rb [-hr] [-w width] [-a aspect] file

require 'GD'
require 'getopts'

scrnwidth = 80
aspect_ratio = 6.0 / 10.0

def usage(string = nil)
	puts "error: " + string if string
	$stderr.puts "usage: #{$0} [-hr] [-w width] [-a aspect] file"
	exit 1
end

usage("invalid option") if !getopts("hr", "a:", "w:")
if $OPT_w
	scrnwidth = $OPT_w.to_i
	if scrnwidth <= 1
		usage("bad width")
	end
end
if $OPT_a
	$OPT_a.gsub(/[[:space:]]/, '') =~
	  /^([[:digit:]]+\.?[[:digit:]]*?)(\/([[:digit:]]+\.?[[:digit:]]*))?$/
	usage("bad number") if !$1 || $1.to_f == 0.0 || ($3 && $3.to_f == 0.0)
	aspect_ratio = $3 ? ($1.to_f / $3.to_f) : $1.to_f
	usage("negative ratio") if aspect_ratio == 0.0
end

usage("no file name") if !(name = ARGV.shift)
case name
when /\.jpe?g$/i
	img = GD::Image.newFromJpeg(open(name, 'r'))
when /\.png$/i
	img = GD::Image.newFromPng(open(name, 'r'))
when /\.xbm$/i
	img = GD::Image.newFromXbm(open(name, 'r'))
when /\.xpm$/i
	img = GD::Image.newFromXpm(open(name, 'r'))
else
	usage("invalid file name")
end

gradient =
  ' .\'`,^:";~-_+<>i!lI?/\|()1{}[]rcvunxzjftLCJUYXZO0Qoahkbdpqwm*WMB8&%$#@'
gradient.reverse! if !$OPT_r
width, height = img.bounds
nwidth = [width, scrnwidth].min
# useful ratios
#  xterm: 6x13, netscape <pre>: 6x10
nheight = (height.to_f * aspect_ratio * (nwidth.to_f / width.to_f)).to_i
usage("width too small") if nwidth <= 0
usage("height too small") if nheight <= 0

$stderr.printf("%s: %d x %d, %d colors -> %d x %d\n", name, width, height,
  img.colorsTotal, nwidth, nheight)

nimg = GD::Image.new(nwidth, nheight)
img.copyResized(nimg, 0, 0, 0, 0, nwidth, nheight, width, height)

if $OPT_h
	filters = [[/[[:space:]]*$/, ''], [/&/, '&amp;'], [/</, '&lt;'],
	  [/>/, '&gt;'], [/\[/, '&#91;'], [/\]/, '&#93']]
else
	filters = [[/[[:space:]]*$/, '']]
end

(0...nheight).each {|h|
	line = (0...nwidth).collect {|w|
		pixcolor = nimg.getPixel(w, h)
		colors = nimg.red(pixcolor) + nimg.green(pixcolor) + nimg.blue(pixcolor)
		gradient[((colors.to_f / 765.1) * gradient.size).floor, 1]
	}.join
	filters.each {|*r| line.gsub!(r[0], r[1])}
	puts line
}
