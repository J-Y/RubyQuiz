require 'xoxo'

require 'open-uri'
require 'pp'

puts "RyanKing's Odeo profile:"
pp XOXO.load(open("http://odeo.com/profile/RyanKing/xoxo").read)

puts
puts "A sample OPML reading list, converted to XOXO and loaded:"

pp XOXO.load(open("http://decafbad.com/2005/10/gopher-ng/xsltproc/?xslAddr=http%3A%2F%2Fdecafbad.com%2F2005%2F10%2Fgopher-ng%2Fopml-to-xoxo.xsl&docAddr=http%3A%2F%2Fhosting.opml.org%2Fdave%2Fdemos%2ForiginalBloggersList.opml").read)
