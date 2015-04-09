# = ai/csp/int.rb
# Copyright (C) 2005 Jonathan Sillito, sillito@gmail.com
#
# Written and maintained by Jonathan Sillito. Please report bugs, make
# suggestions or otherwise get involved by email at sillito@gmail.com.
#
# For details see AI::CSP::INT.
#
# $Id: $
#

require 'ai/csp/constraint'

module AI
module CSP

# This is an effort to provide constraints over variables with integer
# domains, and in particular domains such that domain[i] == i.  With
# this assumption many of these can significantly improve performance
# over generic constraints.
#
# Important note this is still very much a work in progress!
#
module INT

    # Only slightly more efficient than a more generic version...
    class BinaryEqual < Constraint
        def initialize(v1, v2) 
            super(v1, v2) {|a,b| a==b}
        end

        def propagate(variable, level)
            v = @variables[@variables.index(variable) - 1]
            return true if v.instantiated?

            v.each_value_with_index(level) { |value, index|
                v.prune(level, index) unless value == variable.value
            }
            not v.domain_empty?(level)
        end
    end

    class BinaryNotEqual < Constraint
        def initialize(v1, v2) 
            super(v1, v2) {|a,b| a!=b}
        end

        # O(1)
        def propagate(variable, level)
            v = @variables[@variables.index(variable) - 1]
            return true if v.instantiated? or v.pruned?(level, variable.value)
            v.prune(level,variable.value)
            not v.domain_empty?(level)
        end
    end

    class Equal < Constraint
        def initialize(*variables)
            super(*variables) { |*vals|
                # this could likely be made more efficient ...
                values = Set.new(vals)
                values.length == 1
            }
        end

        # While expensive, this can prune huge amounts from the search
        # space and will generally be a net performance gain.
        def propagate(variable, level)
            uninstantiated_variables.each {|v|
                v.each_value_with_index(level) { |value, index|
                    v.prune(level, index) unless value == variable.value
                }
                return false if v.domain_empty?
            }
            true
        end
    end

    # Ensures no two of these have the same value. TODO Could be
    # called AllDifferent.
    class NotEqual < Constraint
        def initialize(*variables)
            super(*variables) { |*values|
                unique_values = Set.new(values)
                unique_values.length == values.length
            }
        end

        def propagate(variable, level)
            value_index = variable.value
            uninstantiated_variables.each { |v|
                next if v.pruned?(level, value_index)
                v.prune(level, value_index)
                return false if v.domain_empty?(level)
            }
            true
        end
    end

end
end
end
