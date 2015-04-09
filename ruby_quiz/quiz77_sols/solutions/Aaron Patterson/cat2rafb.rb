# Solution to [QUIZ] cat2rafb (#77) 
# By Aaron Patterson
require 'rubygems'
require 'mechanize'
require 'getoptlong'

PASTE_URL = 'http://rafb.net/paste/'
RUBY_URL  = 'http://rubyurl.com/'

# Get options
parser = GetoptLong.new
parser.set_options( ['--lang', '-l', GetoptLong::OPTIONAL_ARGUMENT],
                    ['--nick', '-n', GetoptLong::OPTIONAL_ARGUMENT],
                    ['--desc', '-d', GetoptLong::OPTIONAL_ARGUMENT],
                    ['--cvt_tabs', '-t', GetoptLong::OPTIONAL_ARGUMENT]
                  )
opt_hash = {}
parser.each_option { |name, arg| opt_hash[name.sub(/^--/, '')] = arg }

# Get the text to be uploaded
buffer = String.new
if ARGV.length > 0
  ARGV.each { |f| File.open(f, "r") { |file| buffer << file.read } }
else
  buffer = $stdin.read
end

agent = WWW::Mechanize.new

# Get the Paste() page
page = agent.get(PASTE_URL)
form = page.forms.first
form.fields.name('text').first.value = buffer

# Set all the options
opt_hash.each { |k,v| form.fields.name(k).first.value = v }

# Submit the form
page = agent.submit(form)
text_url = page.uri.to_s

# Submit the link to RUBY URL
page = agent.get(RUBY_URL)
form = page.forms.first
form.fields.name('rubyurl[website_url]').first.value = text_url
page = agent.submit(form)
puts page.links.find { |l| l.text == l.href }.href
