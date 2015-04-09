class Rule
	attr_reader :thing, :other_thing;
	def initialize(thing, other_thing)
		@thing = thing
		@other_thing = other_thing;
	end
	def ===(otherRule)
		self.class == otherRule.class && same_things?(otherRule)
	end
	def ==(otherRule)
		self === otherRule
	end
	def same_things?(otherRule)
		@thing == otherRule.thing && @other_thing == otherRule.other_thing
	end
	def switched_things?(otherRule)
		@thing == otherRule.other_thing && @other_thing == otherRule.thing
	end
	def <=>(other)
		if(self.class != other.class) 
			class_order = [AllAreRule, NoneAreRule, NotAllAreRule, SomeAreRule]
			return class_order.index(self.class) <=> class_order.index(other.class)
		elsif(thing != other.thing)
			return thing <=> other.thing
		else
			return other_thing <=> other.other_thing
		end
	end
	def contradicts?(other)
		return Rule.contradiction?(self, other)
	end
	def Rule.contradiction?(rule1, rule2)
		return false if rule1.class == rule2.class
		return false unless (rule1.same_things?(rule2) || rule1.switched_things?(rule2))
		return true if(rule1.class == NoneAreRule && (rule2.class == AllAreRule || rule2.class == SomeAreRule))
		return true if(rule2.class == NoneAreRule && (rule1.class == AllAreRule || rule1.class == SomeAreRule))
		return false unless (rule1.same_things?(rule2))
		return true if(rule1.class == AllAreRule && rule2.class == NotAllAreRule)
		return true if(rule2.class == AllAreRule && rule1.class == NotAllAreRule)
		return false
	end
end

class AllAreRule < Rule
	def extrapolate(other=nil)
		return [
			SomeAreRule.new(thing, other_thing),
			SomeAreRule.new(other_thing, thing),
		] unless other
		if(other.class == AllAreRule)
			return [AllAreRule.new(thing, other.other_thing)] if(other.thing == other_thing)
			return [AllAreRule.new(other.thing, other_thing)] if(other.other_thing == thing)
		end
		if(other.class == SomeAreRule)
			return [
				SomeAreRule.new(other.thing, other_thing)
			] if thing == other.other_thing
		end
		if(other.class == NoneAreRule)
			return [
				NoneAreRule.new(other.thing, thing),
				NoneAreRule.new(thing, other.thing),
			] if(other.other_thing == other_thing)
		end		
		[]
	end
	def supercedes?(other)
		same_things?(other) && other.class == SomeAreRule
	end	
	def to_s
		"all #{thing} are #{other_thing}."
	end
end

class SomeAreRule < Rule
	def extrapolate(other=nil)
		return [
			SomeAreRule.new(other_thing, thing),
		] unless other
		if(other.class == AllAreRule)
			return [
				SomeAreRule.new(thing, other.other_thing)
			] if other_thing == other.thing
		end
		[]
	end
	def supercedes?(other)
		false
	end
	def to_s
		"some #{thing} are #{other_thing}."
	end
end
class NotAllAreRule < Rule
	def extrapolate(other=nil)
		return [
			SomeAreRule.new(thing, other_thing),
			SomeAreRule.new(other_thing, thing),
		] unless other
		[]
	end
	def supercedes?(other)
		same_things?(other) && other.class == SomeAreRule
	end		
	def to_s
		"some #{thing} are not #{other_thing}."
	end
end
class NoneAreRule < Rule
	def extrapolate(other=nil)
		return [NoneAreRule.new(other_thing, thing)] unless other
		if(other.class == AllAreRule)
			return [
				NoneAreRule.new(other.thing, thing),
				NoneAreRule.new(thing, other.thing),
			] if(other.other_thing == other_thing)
		end				
		[]
	end	
	def supercedes?(other)
		false
	end	
	def to_s
		"no #{thing} are #{other_thing}."
	end		
end

class Inference
	attr_reader :rules;
	def initialize
		@rules = [];
	end
	def process(command)
		begin
			case command.downcase
				when /all (.*) are ([^\.]*)\.?/ : addRule(AllAreRule.new($1,$2))
				when /no (.*) are ([^\.]*)\.?/ : addRule(NoneAreRule.new($1,$2))
				when /some (.*) are not ([^\.]*)\.?/ : addRule(NotAllAreRule.new($1,$2))
				when /some (.*) are ([^\.]*)\.?/ : addRule(SomeAreRule.new($1,$2))
				when /are all ([^\?]*)\??/ : checkRuleFromStrings(AllAreRule, $1)
				when /are any (.*) not ([^\?]*)\??/ : checkRule(NotAllAreRule.new($1,$2))
				when /are any ([^\?]*)\??/ : checkRuleFromStrings(SomeAreRule, $1)
				when /are no ([^\?]*)\??/ : checkRuleFromStrings(NoneAreRule, $1)
				when /describe ([^\.]*)\.?/ then
					name = $1
					@rules.select { |x|
						x.thing == name && x.other_thing != name
					}.sort.collect { |x|
						x.to_s.capitalize
					}
				else "I don't understand."
			end
		rescue String => e
			e
		end
	end
	def checkRuleFromStrings(rule, strings)
		known_things = @rules.collect { |x| [x.thing, x.other_thing] }.flatten.uniq
		words = strings.split
		(1..(words.length-1)).each { |breakpoint|
			thing1 = words[0..breakpoint-1].join(" ")
			thing2 = words[breakpoint..-1].join(" ")
			if(known_things.include?(thing1))
				if known_things.include?(thing2)
					return checkRule(rule.new(thing1, thing2))
				else
					return "I don't know anything about #{thing2}."
				end
			elsif known_things.include?(thing2)
				return "I don't know anything about #{thing1}."
			end
		}
		return "I don't know anything about those things."
	end
	def checkRule(rule)
		if(@rules.include? rule)
			"Yes, #{rule}"
		elsif(!(contradicting = @rules.select { |x| x.contradicts?(rule) }).empty?)
			strength =  [AllAreRule, NoneAreRule, NotAllAreRule, SomeAreRule]; 
			sorted = contradicting.sort_by { 
				|x|(x.thing  == rule.thing) ? 0 : 1 
			}.sort_by {
				|x| strength.index(x.class) 
			}
			"No, #{sorted[0]}"
		else
			"I don't know."
		end
	end
	def rule_known?(rule)
		@rules.include?(rule) || @rules.any? { |x| x.supercedes?(rule) }
	end
	def addRule(rule)
		return "I know." if rule_known?(rule)
		newRules = @rules.clone
		extrapolated = [rule]
		until extrapolated.empty?
			newRule = extrapolated.delete_at(0)
			if @rules.any? { |other| newRule.contradicts?(other) }
				return "Sorry, that contradicts what I already know."
			end
			extrapolated.concat(newRule.extrapolate())
			newRules.each { |rule|
				extrapolated.concat(newRule.extrapolate(rule))
			}
			newRules << newRule
			extrapolated = extrapolated.delete_if { |x| 
				newRules.include? x || 
					newRules.any? { |y| y.supercedes?(x) }
			}
		end
		@rules = newRules.delete_if { |rule1| 
			rule1.thing == rule1.other_thing ||
				newRules.any? { |rule2| rule2.supercedes?(rule1) } 
		}
		return "OK."
	end
end

if $0 == __FILE__
  engine = Inference.new
  while(line = gets.chomp)
	  if line.length > 0
		  break if "quit" === line.downcase || "exit" === line.downcase
		  puts engine.process(line)
	  end
	  STDOUT.flush
  end
end