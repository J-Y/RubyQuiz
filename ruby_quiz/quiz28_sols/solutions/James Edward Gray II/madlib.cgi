#!/usr/local/bin/ruby

MADLIBS = "../public_html/madlibs"
REPLACE = /\(\(\s*((?:\w+\s*:\s*)?)(.+?)\s*\)\)/m

require "cgi"
require "erb"

query = CGI.new("html4")
files = Dir[File.join(MADLIBS, "*.madlib")].
        map { |f| File.basename(f, ".madlib").tr("_", " ") }
title = nil

content = case query["mode"]
when "questions"
	title = query["madlib"]
	madlib = File.read( File.join( MADLIBS,
	                               "#{query['madlib'].tr(' ', '_')}.madlib" ) )
	count = 0
	seen = Hash.new(false)

	query.form("post") do
		query.hidden("mode", "display") +
		query.hidden("madlib", query["madlib"]) +
		query.dl do
			madlib.scan(REPLACE).inject("") do |fields, (key, question)|
				key = if key.length > 0
					key[/\w+/]
				else
					next fields if seen[question]
					(count += 1).to_s
				end
				seen[key] = true

				fields += query.dt("style" => "font-weight: normal") do
					"Give me #{query.b { question }}."
				end
				fields += query.dd { query.text_field(key) }
			end
		end +
		query.submit("finish")
	end
when "display"
	title = query["madlib"]
	madlib = File.read( File.join( MADLIBS,
	                               "#{query['madlib'].tr(' ', '_')}.madlib" ) )
	count = 0

	madlib.split(/\n(?:\s*\n)+/).inject("") do |result, para|
		result += query.p do
			para.gsub(REPLACE) do
				if $1.length > 0
					query[$1[/\w+/]]
				elsif query.has_key?($2)
					query[$2]
				else
					query[(count += 1).to_s]
				end
			end
		end
	end +
	query.p { "&nbsp;" } * 7
else # choose
	query.p { "Please choose a Madlib from the following list:" } +
	query.form("get") do
		query.hidden("mode", "questions") +
		query.popup_menu("madlib", *files) + " " +
		query.submit("choose")
	end +
	query.p { "&nbsp;" } * 10
end

include ERB::Util
page = ERB.new(DATA.read, nil, "%")
query.out { page.result(binding) }

__END__
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
                      "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<title>Ruby Quiz</title>
	<link rel="stylesheet" type="text/css" href="../quiz.css" />
</head><body>
	<div id="page">
		<div id="header"><span class="ruby">Ruby</span>
		                 <span class="quiz">Quiz</span></div>
		<div id="content">
			<span class="title"><%= title || "Ruby Quiz Madlibs"%></span>
			<%= content %>
		</div>
		<div id="logo"><img src="../images/ruby_quiz_logo.jpg" alt=""
		                    width="157" height="150" /></div>
		<div id="links">
			<span class="title">Madlibs</span>
			<ol>
% files.each do |file|
				<li><a href="madlib.cgi?mode=questions&madlib=<%= u file %>"><%=
				    file
				%></a></li>
% end
			</ol>
		</div>
		<div id="footer">&nbsp;</div>
	</div>
</body>
</html>
