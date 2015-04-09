#!/usr/local/bin/ruby
require 'net/http'
require 'uri'

LANG = %w{C89 C C++ C# Java Pascal Perl PHP PL/I Python Ruby Scheme SQL VB XML 
          Plain\ Text}
TABS = %w{No 2 3 4 5 6 8}
RAFB, RURL = %w{http://rafb.net/paste/paste.php
                http://rubyurl.com/rubyurl/create}.map { |u| URI.parse(u) }

rurlmode = !ARGV.delete('-R') and output_ofs = (ARGV.delete('-r') ? -1 : 0)
(form = {'lang' => (rurlmode ? 'Ruby' : 'Plain Text'), 
         'nick' => ENV['USER'] || 'unknown', 
         'desc' => '', 
         'cvt_tabs' => 'No',
         'text' => nil}).keys.each do |key|
  ARGV.reject! { |a| form[key] = $1 if a =~ /-#{key[0,1]}=?(.*)/ }
end
form['lang'] = LANG.detect {|l| l.casecmp(form['lang']) == 0} or
  raise "Unrecognized language (allowed values are #{LANG.inspect})" 
form['cvt_tabs'] = TABS.detect {|l| l.casecmp(form['cvt_tabs']) == 0} or
  raise "Unrecognized tab length (allowed values are #{TABS.inspect})" 
form['text'] ||= ARGF.read

begin
  puts(((q = [[RAFB, form]]).map do |url,form|
    if (res = Net::HTTP.post_form(url,form)).is_a?(Net::HTTPRedirection)
      if (loc = res['location']) =~ /\/rubyurl\/show\/(.*)/
        "http://rubyurl.com/#$1"
      else
        rfb = "http://rafb.net#{loc}"
        q << [RURL, {'rubyurl[website_url]' => rfb}] if rurlmode
        rfb
      end
    else
      res.error!
    end 
  end)[(output_ofs || 0)..-1].join("\n"))
rescue
  $!.set_backtrace([]) and raise
end

