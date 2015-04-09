#!/usr/bin/env ruby
#
# q115.rb - solution to rubyquiz #115 (Mailing List Files)
# Lou Scoras <louis.j.scoras@gmail.com>
# February 28, 2007
#
# = Dependancies
#
# It felt like I was cheating a lot in this quiz since I made use of several
# great libraries to do everything for me =)  If you want to play with the
# script, you'll need to get a hold of:
#
# ActionMailer::  This was used for access to TMail.  You might be able to use
#                 TMail by itself, but I haven't tested it and rails might
#                 have made some modifications.
#
# Elif::          This handy little library reads files backwards.  This was
#                 actually a solution from a previous quiz ({64 - Port a
#                 Library}[http://www.rubyquiz.com/quiz64.html]). Plus it's
#                 from James so you know it's good stuff ;)
#
# Hpricot::       Used this little gem (no not the kind of package) to do the
#                 scraping to get all the solutions for a quiz.  Awesome, just
#                 awesome!
#
# = The Script
#
# The messages in the archive are pretty close to being readable by TMail.
# Each page is just missing the correct mime header to let the mail parser
# know it's actually got attachments.
#
# After pulling out all the html artifacts, we still need to find the mime
# boundary.  An easy way to do this is just look for the content-disposition
# headers for the attachments and then look above them to find the boundary.
#
# 1. Look for 'Content-Disposition: attachment'
# 2. Look for the first line above that which is not a mail header -- that's
#    what elif is helping with.
# 3. That line is the mime boundary.  Add the header into the TMail object and
#    then you can read the attachments as normal
#
# = Running
#
# The script implements the command line interface mentioned in the quiz
# description.  You just give it the name of a ruby-talk message id and it
# will fetch the attachments into the current directory.  If you follow the
# number by a path you can change the output directory.
#
#     $ q115 190780 outdir
#
# As an additional feature, you can also provide the number of the quiz
# prefixed with a 'q' character.  In this case, all of the solutions will be
# downloaded and put in a subdirectory by solver.  If the solution didn't have
# any attachments it puts the message body into a file called solution.txt.

require 'action_mailer'
require 'cgi'
require 'delegate'
require 'elif'
require 'fileutils'
require 'hpricot'
require 'open-uri'
require 'tempfile'

module Quiz115
class QuizMail < DelegateClass(TMail::Mail)
  class << self
    attr_reader :archive_base_url

    def archive_base_url
      @archive_base_url ||
      "http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/"
    end

    def solutions(quiz_number)
      doc   = Hpricot(open("http://www.rubyquiz.com/quiz#{quiz_number}.html"))
      (doc/'#links'/'li/a').collect do |link|
        [CGI.unescapeHTML(link.inner_text), link['href']]
      end
    end
  end

  def initialize(mail)
    temp_path = to_temp_file(mail)
    boundary  = MIME::BoundaryFinder.new(temp_path).find_boundary

    @tmail = TMail::Mail.load(temp_path)
    @tmail.set_content_type 'multipart', 'mixed',
      'boundary' => boundary if boundary

    super(@tmail)
  end

  private

  def to_temp_file(mail)
    temp = Tempfile.new('qmail')

    temp.write(if (Integer(mail) rescue nil)
      url = self.class.archive_base_url + mail
      open(url) { |f| x = cleanse_html f.read }
    else
      web = URI.parse(mail).scheme == 'http'
      open(mail) { |m| web ? cleanse_html(m.read) : m.read }
    end)

    temp.close
    temp.path
  end

  def cleanse_html(str)
    CGI.unescapeHTML(
      str.gsub(/\A.*?<div id="header">/mi,'').gsub(/<[^>]*>/m, '')
    )
  end
end

module MIME
  class BoundaryFinder

    ##
    # Create a parser to find the mime boundary
    #
    def initialize(file)
      @elif = ::Elif.new(file)
      @in_attachment_headers = false
    end

    ##
    # Find the mime boundary marker.  Only returns the marker if itcan find an
    # attachment, otherwise for quiz purposes there's no reason to find it: id
    # est we don't care about multipart/alternative messages, et cetera.
    #
    def find_boundary
      while line = @elif.gets
        if @in_attachment_headers
          if boundary = look_for_mime_boundary(line)
            return boundary
          end
        else
          look_for_attachment(line)
        end
      end
      nil
    end

    private

    def look_for_attachment line
      if line =~ /^content-disposition\s*:\s*attachment/i
        puts "Found an attachment" if $DEBUG
        @in_attachment_headers = true
      end
    end

    def look_for_mime_boundary line
      unless line =~ /^\S+\s*:\s*/ || # Not a mail header
             line =~ /^\s+/           # Continuation line?
        puts "I think I found it...#{line}" if $DEBUG
        line.strip.gsub(/^--/, '')
      else
        nil
      end
    end
  end
end
end

include Quiz115
include FileUtils

def process_mail(mailh, outdir)
begin
  t = QuizMail.new(mailh)
  if t.has_attachments?
    t.attachments.each do |attachment|
      outpath = File.join(outdir, attachment.original_filename)
      puts "\tWriting: #{outpath}"
      File.open(outpath, 'w') do |out|
        out.puts attachment.read
      end
    end
  else
    outfile = File.join(outdir, 'solution.txt')
    File.open(outfile, 'w') {|f| f.write t.body}
  end
rescue => e
  puts "Couldn't parse mail correctly. Sorry! (E: #{e})"
end
end

def to_dirname(solver)
solver.downcase.delete('!#$&*?(){}').gsub(/\s+/, '_')
end

query  = ARGV[0]
outdir = ARGV[1] || '.'

unless query
$stderr.puts "You must specify either a ruby-talk message id, or a
quiz number (prefixed by 'q')"
exit 1
end

if query =~ /\Aq/i
quiz_number = query.sub(/\Aq/i, '')
puts "Fetching all solutions for quiz \##{quiz_number}"

QuizMail.solutions(quiz_number).each do |solver, url|
  puts "Fetching solution from #{solver}."

  dirname    = to_dirname(solver)
  solver_dir = File.join(outdir, dirname)

  mkdir_p solver_dir
  process_mail(url, solver_dir)
end
else
process_mail(query, outdir)
end

exit 0
