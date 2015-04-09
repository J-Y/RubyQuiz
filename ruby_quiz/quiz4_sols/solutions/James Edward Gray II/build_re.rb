#!/usr/bin/env ruby

class Regexp
	def self.build( *nums )
		nums = nums.map { |e| Array(e) }.flatten.map { |e| String(e) }
		nums = nums.sort_by { |e| [-e.length, e] }
		
		patterns = [ ]
		while nums.size > 0
			eq, nums = nums.partition { |e| e.length == nums[0].length }
			patterns.push(*build_char_classes( eq ))
		end
		
		/(?:#{patterns.join("|")})/
	end
	
	private
	
	def self.build_char_classes( eq_len_strs )
		results = [ ]

		while eq_len_strs.size > 1
			first = eq_len_strs.shift
			if md = /^([^\[]*)([^\[])(.*)$/.match(first)
				chars = md[2]
				matches, eq_len_strs = eq_len_strs.partition do |e|
					e =~ /^#{md[1]}(.)#{Regexp.escape md[3]}$/ and chars << $1
				end
				if matches.size == 0
					results << first
					next
				end
				
				chars = build_short_class(chars.squeeze)
				eq_len_strs << "#{md[1]}[#{chars}]#{md[3]}"
			else
				results << first
			end
		end
		results << eq_len_strs[0] if eq_len_strs.size == 1

		results
	end

	def self.build_short_class( char_class )
		while md = /[^\-\0]{3,}/.match(char_class)
			short = md[0][1..-1].split("").inject(md[0][0, 1]) do |mem, c|
				if (mem.length == 1 or mem[-2] != ?-) and mem[-1, 1].succ == c
					mem + "-" + c
				elsif mem[-2, 2] =~ /-(.)/ and $1.succ == c
					mem[0..-2] + c
				else
					mem + c
				end
			end
			char_class.sub!(md[0], short.split("").join("\0"))
		end
		
		char_class.tr!("\0", "")
		char_class.gsub!(/([^\-])-([^\-])/) do |m|
			if $1.succ == $2 then $1 + $2 else m end
		end
		char_class
	end
end
