require 'uri'
require 'open-uri'
require 'rexml/document'

class Array
	def shuffle!
		original = dup
		size.times {|i| self[i] = original.delete_at(rand(original.size))}
	end
end

module TextMunger
	PLACE_HOLDER = "\0"
	ALPHA = "a-zA-Z"
	REGEX = /(^[^#{ALPHA}]*[#{ALPHA}])(.*?)([#{ALPHA}][^#{ALPHA}]*$)/
	
	def self.munge_text(text)
		text.split(/\b/).collect {|w| munge_word(w)}.join
	end
	
	def self.find_unambiguous_match(munged, anEnumerable)
		matches = anEnumerable.find_all { |x| eq_munged(x, munged.to_s) }
		matches.size == 1 ? matches.first : nil
	end
	
	private
	
	def self.munge_word(word)
		return word unless word =~ REGEX
		head, mid, tail = $~.captures
		chars = []
		mid_template = mid.gsub(/[#{ALPHA}]/) { |c| chars << c; PLACE_HOLDER }
		template = [head, mid_template, tail].join
		chars.shuffle!
		template.gsub(/#{PLACE_HOLDER}/) { chars.pop }		
	end
	
	def self.eq_munged(word, other_word)
		word.split(//).sort == other_word.split(//).sort and
		md = word.match(REGEX) and
		other_md = other_word.match(REGEX) and			
		[md.captures.first, md.captures.last] == [other_md.captures.first, other_md.captures.last]
	end
end

class Object
	alias method_missing_orig method_missing
	
	def method_missing(sym, *args, &block)
		all_methods = [public_methods, protected_methods, private_methods].flatten
		if method = TextMunger::find_unambiguous_match(sym, all_methods)
			send(method, *args, &block)
		else 
			method_missing_orig(sym, *args, &block)
		end
	end
end

class Module
	alias const_missing_orig const_missing
	
	def const_missing(sym)
		if constant = TextMunger::find_unambiguous_match(sym, constants)
			module_eval(constant)
		else 
			const_missing_orig(sym)
		end
	end
end

def get_text
	url = "http://www.rubyquiz.com/quiz76.html"
	xml = open(url) do |f|
		doc = REXML::Document.new(f)
		nodes = doc.elements.to_a('//div[@id="content"]//')
		text_blocks = nodes.collect {|a| a.texts.collect {|t| t.value}.join(" ")} 
		text_blocks.delete_if { |b| b.strip.empty? }
	end
end

ptus gtt_xeet.cllocet {|t| TexMtunegr::mgnue_txet(t)}.jion("\n" * 2)








