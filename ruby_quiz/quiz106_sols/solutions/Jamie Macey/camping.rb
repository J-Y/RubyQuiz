require 'rubygems'
require 'camping'
require 'chess960'

Camping.goes :Chess

module Chess::Controllers
 # main page
 class Index < R '/'
   def get
     @chess = Chess960.new
     render :index
   end
 end

 # image passthrough
 class Images < R '/images/(.+)'
   MIME_TYPES = {'.png' => 'image/png'}
   PATH = __FILE__[/(.*)\//, 1]

   def get(path)
     @headers['Content-Type'] = MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain"
     unless path =~ /\.\./ # sample test to prevent directory traversal attacks
       @headers['X-Sendfile'] = "#{PATH}/images/#{path}"
     else
       "404 - Invalid path"
     end
   end
 end
end

module Chess::Views
 def layout
   html do
     body do
       style :type => 'text/css' do
         "#chess { border-collapse: collapse;
                   float: left; margin-right: 2em; } " +
         ".dark { background-color: #888; } " +
         ".light { background-color: #ddd; } " +
         ".thin { width: 50em; } "
       end
       self << yield
     end
   end
 end

 def index
   c = 0
   table.chess! do
     @chess.board.each do |row|
       c = 1 - c
       tr do
         row.each do |tile|
           c = 1 - c
           td :class => c==0 ? 'light' : 'dark' do
             img :src => "images/#{tile}.png"
           end
         end
       end
     end
   end
   h1 "Chess 960"
   div.thin do
     text "<p>Randomly created board, using the #{a 'Bodlaendar', :href =>
        "http://en.wikipedia.org/wiki/Chess960#Determining_a_starting_position"}
        method for generating piece order.</p>"
     p "Result was #{@chess.board.last.join(", ")}."
   end
 end
end
