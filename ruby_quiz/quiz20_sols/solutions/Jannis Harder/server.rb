#!/usr/bin/env ruby
require 'webrick'
require 'wordizer'
include WEBrick
PRE = '<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">
 <head>
   <title>Phone Number Wordizer</title>
 </head>
 <body>
'
POST ='    <form action="/" method="get">
     <div>Phone number: <input type="text" name="pn"%VAL% /></div>
     <div><input type="checkbox" name="condig"%C% />Allow consecutive digits</div>
     <div><input type="submit" name="action" value="Go!" /></div>
   </form>
   <div><small>by <a href="mailto:jannis@harderweb.de">Jannis Harder</a></small></div>
 </body>
</html>'

s = HTTPServer.new( :Port => (ARGV[0]||2005).to_i )

$inwork = []
$cache = [nil]*(ARGV[1]||150).to_i
f=File.open(File.expand_path(ARGV[1]||"2of4brif.txt"))
$w=Wordizer.new(f)
f.close




def msg(msg)
   "    <p><strong>#{msg}</strong></p>\n"
end
def connum(condig,number)
 (condig ? 'a' : 'b')+number
end

s.mount_proc("/") do |req, res|
 res.body = PRE.dup
 if req.query["pn"]
   number = req.query["pn"].tr("^0-9","")
   condig = req.query["condig"]
   cnum = connum(condig,number)
   if number.size == 0
   elsif number.size > 15
     res.body << msg("Phone number too long.")
   elsif e = $cache.find{|z|z and z[0]==cnum}
     if e[1].empty?
       res.body << msg("No match found")
     else
       res.body << msg("Results:")
       res.body << "    <div>"+e[1].join("</div>\n    <div>")+"</div><p></p>\n"
     end
     $cache[$cache.index(e),1]=[]
     $cache << e
   else
     Thread.new(number) do
       $inwork << cnum
       $cache << [cnum, $w.wordize(number,condig)]
       $cache.shift
       $inwork.delete(number)
     end unless $inwork.include? cnum
     res['Refresh']="1;url=/?pn=#{WEBrick::HTTPUtils.escape(req.query['pn'])}#{
     req.query['condig'] ? '&condig=on' : ''}&action=Go%21"
     res.body << msg("Please wait...")
   end
 end
 res.body << POST.gsub(/(%VAL%|%C%)/) {
   case $1
   when "%VAL%"
   if req.query["pn"]
     ' value="'+WEBrick::HTMLUtils.escape(req.query["pn"])+'"'
   else
    ''
   end
   when "%C%"
     if req.query["condig"]
     ' checked="checked"'
     else
      ''
     end
   end
 }
 res['Content-Type'] = "text/html"
end
s.mount_proc("/favicon.ico") do
end

trap("INT"){ exit! }
s.start
__END__
