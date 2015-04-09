#!/usr/bin/env ruby
#
# name_picker.rb
# RubyQuiz #129 (http://www.rubyquiz.com/quiz129.html)
# Bob Showalter
#
# Lone Star Ruby Conference Name Picker
#
# Usage: ruby name_picker.rb names.yml
#
# names.yml is a YAML file containing a hash of attendees, indexed by
# name. Each entry is a hash of additional optional entries. Example:
#
#   Yukihiro Matsumoto:            # attendee's name (must be unique)
#     nick: matz                   # nickname/handle
#     org: www.ruby-lang.org       # attendee's organization
#     role: Presenter              # attendee's role
#
# Only the attendee's name is required. All other entries are optional.
#
# The program starts a local WEBrick server. Each visit to the home page will
# display a random attendee's name, along with his or her nick, organization,
# and role, if present. Other values can be suported by modifying the template
# below.
#
# Names that have already been issued are written to a file which is reloaded
# if the application is restarted. When all of the names have been issued,
# this "memo" file is cleared and the issuing of names starts over.

# server address/port to bind
ADDR = '127.0.0.1'
PORT = '4242'

# file to save names already served. this is reloaded when the application is
# restarted.
MEMO_FILE = './names.memo'

# template to display an attendee, name will be in @name, additional attributes
# in @attr
TEMPLATE = <<EOT
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="Content-Language" content="en-us" />
    <base href="http://lonestarrubyconf.com"/>
    <title>Lone Star Ruby Conference</title>
    <link href="/stylesheets/main.css" rel="stylesheet" type="text/css" media="all" />
    <style type="text/css">
    #content { padding: 60px 0 }
    #content h1 { font-size: 500% }
    #content h2 { font-size: 250% }
    </style>
  </head>
  <body>
    <div id="wrapper">
      <div id="content">
        <h1 id="site_title"/>
        <h1><%= h @name %></h1>
        <% if @attr['nick'] %><h2>"<%= h @attr['nick'] %>"</h2><% end %>
        <% if @attr['org'] %><h2>(<%= h @attr['org'] %>)</h2><% end %>
        <% if @attr['role'] %><h2><em><%= h @attr['role'] %></em></h2><% end %>
      </div>
    </div>
  </body>
</html>
EOT

require 'webrick'
require 'erb'
require 'yaml'

include WEBrick

class Names
  # load names from file and reload memo file if present
  def self.load(path)
    @names = YAML.load_file(ARGV.first) rescue abort($!.to_s)
    @names.respond_to?(:keys) or abort "Invalid names file format"
    @names.keys.size > 0 or abort "No names found"
    @memo = []
    @memo = YAML.load_file(MEMO_FILE) if File.exists?(MEMO_FILE)
  end

  # pick a random name. add it to the memo file so we don't pick it again.
  # however, when all names have been picked, clear the memo file and start
  # issuing names again.
  def self.pick
    avail = @names.keys - @memo
    if avail.empty?
      @memo = []    # start recycling names
      return self.pick
    end
    name = avail[rand(avail.size)]
    @memo << name
    File.open(MEMO_FILE, 'w') {|f| YAML.dump(@memo, f)}
    [ name, @names[name] || {} ]
  end
end


class IndexServlet < HTTPServlet::AbstractServlet
  include ERB::Util

  def do_GET(req, resp)
    resp['Content-Type'] = "text/html"
    @name, @attr = Names.pick
    resp.body = ERB.new(TEMPLATE).result(binding)
  end
end

abort "Usage: ruby name_picker.rb names.yml" unless ARGV.first
Names.load(ARGV.first)

# start the server (minimal logging)
server = HTTPServer.new :BindAddress => ADDR,
  :Port => PORT,
  :Logger => Log.new(nil, BasicLog::WARN),
  :AccessLog => []
server.mount '/', IndexServlet
puts "Contact me at http://#{server.config[:BindAddress]}:#{server.config[:Port]}/"
server.start