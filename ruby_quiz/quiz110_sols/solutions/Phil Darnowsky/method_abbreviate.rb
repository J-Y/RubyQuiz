class AmbiguousAbbreviationException < Exception
	# @candidates should get an array of symbols that the abbreviation
	# might expand to.
	
	def initialize(*candidates)
		super
		@candidates = candidates
	end

	attr_reader :candidates
end

class Module
	def abbrev(*meths)

		# Do abbrev setup once.
		
		unless (@abbrev_setup_done) then
			@abbrev_expansions = Hash.new([])
			self.class.send(:attr_reader, :abbrev_expansions)

			@abbrev_targets = []

			module_eval do 
				def method_missing(symbol, *args)
					candidates = self.class.abbrev_expansions[symbol.to_sym].dup
					candidates.delete_if {|meth| !(respond_to?(meth))}

					case 
						when candidates.size == 0:
							raise(NoMethodError)
						when candidates.size == 1:
							send(candidates.first, *args)
						else
							# To pass test suite, comment out the raise in
							# the next line and un-comment the line after that.
							# I think this way is better.
							raise(AmbiguousAbbreviationException.new(candidates))
							#candidates
					end
				end
			end

			@abbrev_setup_done = true
		end

		# Build hash of possible expansions.

		module_eval do
			@abbrev_targets += meths
			meths.each do |meth|
				sym = meth.to_sym
				prefix = "#{meth.to_s}"
				prefix.chop!
				while (prefix.length > 0) do
					prefix_sym = prefix.to_sym
					unless @abbrev_targets.include?(prefix_sym) then
						@abbrev_expansions[prefix_sym] += [sym]
					end
					prefix.chop!
				end
			end
		end
	end
end
