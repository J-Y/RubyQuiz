module JobHelper
	def excerpt( textile, id )
		html = sanitize(textilize(textile))
		html.sub!(/<p>(.*?)<\/p>(.*)\Z/m) { $1.strip }
		if $2 =~ /\S/
			"#{html} #{link_to '...', :action => :show, :id => id}"
		else
			html
		end
	end
end
