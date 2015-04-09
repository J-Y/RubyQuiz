#!/usr/bin/env ruby

## Proposed solution to http://www.rubyquiz.org/quiz047.html
## Written by Paul Vaillant (paul.vaillant@gmail.com)
## Permission granted to do whatever you'd like with this code

require 'digest/md5'
require 'cgi'
require 'erb'

## gems are required for sqlite3 and active_record
require 'rubygems'
require 'sqlite3'
require 'active_record'

## Check if the database exists; create it and the table we need if it doesn't
DB_FILE = "/tmp/jobs.db"
unless File.readable?(DB_FILE)
	table_def = <<-EOD
CREATE TABLE postings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        posted INTEGER,
	title VARCHAR(255),
        company VARCHAR(255),
	location VARCHAR(255),
        length VARCHAR(255),
        contact VARCHAR(255),
        travel INTEGER(2), -- 0%, 0-25%, 25-50%, 50-75%, 75-100%
        onsite INTEGER(1),
        description TEXT,
        requirements TEXT,
        terms INTEGER(2), -- C(hourly), C(project), E(hourly), E(pt), E(ft)
        hours VARCHAR(255),
        secret VARCHAR(255) UNIQUE,
        closed INTEGER(1) DEFAULT 0
);
EOD
	db = SQLite3::Database.new(DB_FILE)
	db.execute(table_def)
	db.close
end

## Setup ActiveRecord database connection and the one ORM class we need
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => DB_FILE)
class Posting < ActiveRecord::Base
	TRAVEL = ['0%','0-25%','25-50%','50-75%','75-100%']
	TERMS = ['Contract(hourly)','Contract(project)','Employee(hourly)',
		'Employee(part-time)','Employee(full-time)']
end

class Actions
	ADMIN_SECRET = 's3cr3t'
	@@templates = nil
	def self.template(t)
		unless @@templates
			@@templates = Hash.new
			name = nil
			data = ''
			DATA.each_line {|l|
				if name.nil?
					name = l.strip
				elsif l.strip == '-=-=-=-=-'
					@@templates[name] = data if name
					name = nil
					data = ''
				else
					data << l.strip << "\n"
				end unless l =~ /^\s*$/
			}
			@@templates[name] = data if name
		end
		return @@templates[t]
	end

	def self.dispatch()
		cgi = CGI.new
		begin
			## map path_info to the method that handles it (ie controller)
			## ex. no path_info (/jobs.cgi) goes to 'index'
			##	/search (/jobs.cgi/search) goes to 'search'
			##	/create/save (/jobs.cgi/create/save) goes to 'create__save'
			action = if cgi.path_info
					a = cgi.path_info[1,cgi.path_info.length-1].gsub(/\//,'__')
					(a && a != '' ? a : 'index')
				else
					"index"
				end
			a = Actions.new(cgi)
			m = a.method(action.to_sym)
			if m && m.arity == 0
				resbody = m.call()
			else
				raise "Failed to locate valid handler for [#{action}]"
			end
		rescue Exception => e
			puts cgi.header('text/plain')
			puts "EXCEPTION: #{e.message}"
			puts e.backtrace.join("\n")
		else
			puts cgi.header()
			puts resbody
		end
	end

	attr_reader :cgi
	def initialize(cgi)
		@cgi = cgi
	end

	def index
		@postings = Posting.find(:all, :conditions => ['closed = 0'], :order => 'posted desc', :limit => 10)
		render('index')
	end

	def search
		q = '%' << (cgi['q'] || '') << '%'
		conds = ['closed = 0 AND (description like ? OR requirements like ? OR title like ?)', q, q, q]
		@postings = Posting.find(:all, :conditions => conds, :order => 'posted desc')
		render('index')
	end

	def view
		id = cgi['id'].to_i
		@post = Posting.find(id)
		render('view')
	end

	def create
		if cgi['save'] && cgi['save'] != ''
			post = Posting.new
			post.posted = Time.now().to_i
			['title','company','location','length','contact',
			  'description','requirements','hours'].each {|f|
				post[f] = cgi[f]
			}
			['travel','onsite','terms'].each {|f|
				post[f] = cgi[f].to_i
			}
			post.secret = Digest::MD5.hexdigest([rand(),Time.now.to_i,$$].join("|"))
			post.closed = 0
			if post.save
				@post = post
			end
		end
		render('create')
	end

	def close
		## match secret OR id+ADMIN_SECRET

		secret = cgi['secret']
		if secret =~ /^(\d+)\+(.+)$/
			id,admin_secret = secret.split(/\+/)
			post = Posting.find(id.to_i) if admin_secret == ADMIN_SECRET
		else
			post = Posting.find(:first, :conditions => ['secret = ?', secret])
		end

		if post
			post.closed = 1
			post.save
			@post = post
		else
			@error = "Failed to match given secret to your post"
		end

		render('close')
	end

	## helper methods
	def link_to(name, url_frag)
		return "<a href=\"#{ENV['SCRIPT_NAME']}/#{url_frag}\">#{name}</a>"
	end

	def form_tag(url_frag, meth="POST")
		return "<form method=\"#{meth}\" action=\"#{ENV['SCRIPT_NAME']}/#{url_frag}\">"
	end

	def select(name, options, selected=nil)
		sel = "<select name=\"#{name}\">"
		options.each_with_index {|o,i|
			sel << "<option value=\"#{i}\" #{(i == selected ? "selected=\"1\"" : '')}>#{o}</option>"
		}
		sel << "</select>"
		return sel
	end

	def radio_yn(name,val=1)
		val ||= 1
		radio = "Yes <input type=\"radio\" name=\"#{name}\" value=\"1\" #{(val == 1 ? "checked=\"checked\"": '')}/> / "
		radio << "No <input type=\"radio\" name=\"#{name}\" value=\"0\" #{(val == 0 ? "checked=\"checked\"" : '')} />"
		return radio
	end

	def textfield(name,val)
		return "<input type=\"text\" name=\"#{name}\" value=\"#{val}\" />"
	end

	def textarea(name,val)
		return "<textarea name=\"#{name}\" rows=\"7\" cols=\"60\">" << CGI.escapeHTML(val || '') << "</textarea>"
	end

	def render(name)
		return ERB.new(Actions.template(name),nil,'%<>').result(binding)
	end
end

Actions.dispatch

__END__
index
<%= render('header') %>

<h1>Postings</h1>
<% if @postings.empty? %>
<p>Sorry, no job postings at this time.</p>
<% else %>
<% for post in @postings %>
	<p><%= link_to post.title, "view?id=#{post.id}" %>, <%= post.company %><br />
	<%= post.location %> (<%= Time.at(0).strftime('%Y-%m-%d') %>)</p>
<% end %>
</table>
<% end %>

<%= render('footer') %>

-=-=-=-=-
create
<%= render('header') %>

<h1>Create new Post</h1>
<% if @post %>
<p>Your post has been successfully added. Please note the following
information, as you will need it
to close you post once it has been filled; <br /><br />
Close code: <%= @post.secret %></p>
<p>Thank you</p>
<% else %>
<% if @error %><p class="error">ERROR: <%= @error %></p><% end %>
<%= form_tag "create" %>
<label for="title">Title</label> <%= textfield "title", cgi['title'] %><br />
<label for="company">Company</label> <%= textfield "company", cgi['company'] %><br />
<label for="location">Location</label> <%= textfield "location", cgi['location'] %><br />
<label for="length">Length</label> <%= textfield "length", cgi['length'] %><br />
<label for="contact">Contact</label> <%= textfield "contact", cgi['contact'] %><br />
<label for="travel">Travel</label> <%= select 'travel', Posting::TRAVEL, cgi['travel'] %><br />
<label for="onsite">Onsite</label> <%= radio_yn "onsite", cgi['onsite'] %><br />
<label for="description">Description</label> <%= textarea "description", cgi['description'] %><br />
<label for="requirements">Requirements</label> <%= textarea "requirements", cgi['requirements'] %><br />
<label for="terms">Employment Terms</label> <%= select 'terms', Posting::TERMS, cgi['terms'] %><br />
<label for="hours">Hours</label> <%= textfield "hours", cgi['hours'] %><br />
<input type="submit" name="save" value="create" />
</form>
<% end %>

<%= render('footer') %>

-=-=-=-=-
view
<%= render('header') %>

<% if @post %>
<h1><%= @post.title %></h1>
<table>
<tr><td>Posted</td><td><%=
Time.at(@post.posted.to_i).strftime('%Y-%m-%d') %></td></tr>
<tr><td>Company</td><td><%= @post.company %></td></tr>
<tr><td>Length of employment</td><td><%= @post.length %></td></tr>
<tr><td>Contact info</td><td><%= @post.contact %></td></tr>
<tr><td>Travel</td><td><%= Posting::TRAVEL[@post.travel] %></td></tr>
<tr><td>Onsite</td><td><%= ['No','Yes'][@post.onsite] %></td></tr>
<tr><td>Description</td><td><%= CGI.escapeHTML(@post.description).gsub(/\n/,"<br />\n") %></td></tr>
<tr><td>Requirements</td><td><%= CGI.escapeHTML(@post.requirements).gsub(/\n/,"<br />\n") %></td></tr>
<tr><td>Employment terms</td><td><%= Posting::TERMS[@post.terms] %></td></tr>
<tr><td>Hours</td><td><%= @post.hours %></td></tr>
</table>
<% else %>
<p>ERROR: failed to load given post.</p>
<% end %>

<%= render('footer') %>

-=-=-=-=-
close
<%= render('header') %>

<h1>Close Post</h1>
<% if @post %>
<p>Successfully closed post '<%= @post.title %>' by <%= @post.company %>.</p>
<% elsif @error %>
<p>ERROR: <%= @error %></p>
<% else %>
<p>ERROR: post not successfully closed, no further description of error.</p>
<% end %>

<%= render('footer') %>

-=-=-=-=-
header
<html>
<head>
	<title>Simple Job Site</title>
	<style>
	form { display: inline; }
	</style>
</head>
<body>
<%= link_to "Home", "index" %> |
<%= link_to "Create new Post", "create" %> |
<%= form_tag "close" %>
	<input name="secret" type="text" size="16" />
	<input type="submit" value="close" />
</form> |
<%= form_tag "search" %>
	<input name="q" type="text" size="15" /> <input type="submit" value="search" />
</form><br />

-=-=-=-=-
footer
</body>
</html>
