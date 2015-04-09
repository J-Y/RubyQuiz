require 'set'

class CSP
  attr_accessor :debug
  def initialize
    @vars = {}#string name => domain
    #domain must be an enumerable or at least accept to_set to turn the domain into a set object.  set has a length function
    #must also not be infinite, since I am going to call to_set, which will try to put every value to the domain into a set object
    @constraints = {}
    @debug = false
  end
  
  def add_var(var_name, var_domain)
    if (var_name.class == String || var_name.class == Symbol) && var_domain.class.method_defined?(:to_set)
      @vars[var_name.to_sym] = var_domain.to_set
    else
      print "Error, trying to set variable's name to something other than a string or symbol or trying to set the variable domain to an object that doesn't accept the to_set method."
    end
  end
  
  def add_constraint(csp_constraint)
    if csp_constraint.class == CSPConstraint
      csp_constraint.vars.each{|var|
        (@constraints[var] ||= []) << csp_constraint
      }
    else
      print "Error, trying to add constraint that isn't a constraint."
    end
  end
  
  def run
    @constraints.values.flatten.uniq.each{|constraint| constraint.vars.each{|var|
      if !@vars.has_key?(var)
        print "\nError, #{var} doesn't have a domain\n"
        return false
      end
    }}
    update_vars = basic_arc
    return back_track(@vars.merge(update_vars),{})
  end
  
#  def set_heuristic_for_choosing_variable(proc)
#    if proc.class == Proc
#      @heuristic_for_choosing_variable = proc
#    else
#      print "Error, trying to set the choosing variable heuristic to something other than a proc"
#    end
#  end
  
#  def set_heuristic_for_selecting_next_value(proc)
#    if proc.class == Proc
#      @heuristic_for_selecting_value = proc
#    else
#      print "Error, trying to set the selecting value heuristic to something other than a proc"
#    end
#  end
  
#  def set_default_heuristics
#    set_heuristic_for_selecting_next_value(
#  end
  
  private
  def sort_vars(a,b) #[var name, domain]
    constraints_on_a = (@constraints[a[0]])?(@constraints[a[0]].length):0
    constraints_on_b = (@constraints[b[0]])?(@constraints[b[0]].length):0
    if constraints_on_a == 0
      return -1
    elsif constraints_on_b == 0
      return 1
    elsif a[1].length > b[1].length
      return 1
    elsif b[1].length > a[1].length
      return -1
    elsif constraints_on_a > constraints_on_b
      return -1
    elsif constraints_on_b > constraints_on_a
      return 1
    else
      return 0
    end
  end
  
  def back_track(vars, vals)#vars is a hash of variable=>domain that are unassigned, vals is hash of variables that have been assigned
    var = vars.sort{|a,b| sort_vars(a,b)}[0]
    print "Vars: #{vars.inspect}\nVals: #{vals.inspect}\n" if @debug
    if var == nil
      return vals if test_solution(vals)
    else
      vars = vars.dup
      vars.delete(var[0])
      var[1].each{|val| 
        new_vals = vals.merge({var[0]=>val})
        print "Setting #{var[0]} to #{val}\n" if @debug
        updated_vars = forward_check(@constraints[var[0]],vars, new_vals)
        skip_this_val = false
        print "Updating vars by replacing these vars: #{updated_vars.inspect}\n" if @debug
        updated_vars.each_value{|value| skip_this_val = value.empty?; break if skip_this_val}
        next if skip_this_val
        STDIN.getc if @debug
        ret_val = back_track(vars.merge(updated_vars), new_vals)
        return ret_val if ret_val
      }
    end
    return false
  end
  
  def forward_check(var_constraints,vars,vals)
    ret_val = {}
    updated_vars = vars.dup
    print "number of constraints is #{var_constraints.length}\n" if @debug
    var_constraints.each do |constraint|
      updated_vars.update(ret_val)
      known_vars = {};unknown_vars = {}
      constraint.vars.each do |var|
        known_vars[var] = vals[var] if vals[var]
        unknown_vars[var] = updated_vars[var] unless vals[var]
      end
      fc_result = constraint.forward_check(known_vars,unknown_vars)
      print "results of one of the constraints being forward checked: ",fc_result.inspect,"\n" if @debug
      ret_val.update(fc_result){|key, oldval, newval| oldval.intersection(newval)}
    end if var_constraints
    return ret_val
  end
  
  def basic_arc
    constraints = []
    @constraints.values.flatten.uniq.each do |constraint|
      if constraint.vars.length == 1
        constraints << constraint
      end
    end
    return forward_check(constraints, @vars, {})
  end
  
  def test_solution(vals) #vals is hash of variables in the form [name, value]
    print "Testing this solution: #{vals.inspect}\n" if @debug
    @constraints.values.flatten.uniq.each do |constraint|
      constraint_solution_array = []
      constraint.vars.each{|var|constraint_solution_array<<vals[var]}
      return false unless constraint[*constraint_solution_array]
    end
    return true
  end
  
end

class CSPConstraint
  attr_reader :vars, :func, :ruleset

  def initialize(vars = [], func = nil)
    @vars = []
    vars.each{|var|add_var(var)}
    (@func = func)&&set_func(func)
    @ruleset = nil #is a RuleSet object that is responsible for doing forward checking to prune the domain as variables are given values
  end
  
  def add_var(var)
    if var.class == Symbol || var.class == String
      @vars << var.to_sym
    else
      print "Error, trying to set variable's name to something other than a string or symbol.\n"
    end
  end
  
  def set_func(func_val)
    if func_val.class == Proc
      @func = func_val
    else
      print "Error, trying to set a constraint that isn't executable object.\n"
      @func = nil
    end
  end
  
  def set_rule_set(rule)
    if rule.class == CSPRuleSet
      @ruleset = rule
    else
      print "Error, trying to set a ruleset that isnt a CSPRuleSet object.\n"
    end
  end
  
  def set_all_diff_constraint(val = nil)
    if @func != nil
      print "Warning, replacing this constraint with an all diff constraint.\n"
    end
    if val
      @func = lambda{|*x1|ret_val = true;(0 .. x1.length - 1).each{|lhs| ret_val = x1[lhs] != val;break unless ret_val};ret_val}
    else
      @func = lambda{|*x1|ret_val = true;(0 .. x1.length - 2).each{|lhs| (lhs + 1 .. x1.length - 1).each{|rhs| ret_val = x1[lhs] != x1[rhs];break unless ret_val};break unless ret_val};ret_val}
    end
    set_rule_set(CSPRuleSet.new(nil, handle_forward_check_ne(val)))
  end
  
  def set_all_eq_constraint(val = nil)
    if @func != nil
      print "Warning, replacing this constraint with an all eq constraint.\n"
    end
    if val
      @func = lambda{|*x1|ret_val = true;(0 .. x1.length - 1).each{|lhs| ret_val = x1[lhs] == val;break unless ret_val};ret_val}
    else
      @func = lambda{|*x1|ret_val = true;(0 .. x1.length - 2).each{|lhs| (lhs + 1 .. x1.length - 1).each{|rhs| ret_val = x1[lhs] == x1[rhs];break unless ret_val};break unless ret_val};ret_val}
    end
    set_rule_set(CSPRuleSet.new(nil, handle_forward_check_eq(val)))
  end
  
  def [](*value)
    return func[*value]
  end
  
  def forward_check(known_vars, unknown_vars)
    return @ruleset.forward_check(known_vars, unknown_vars) if @ruleset
    #print "Forward checking, but no ruleset, so returning {}\n"
    return {}
  end
  
  private
  def handle_forward_check_ne(ne_val = nil)#ne_val is value that all values (usually one) in constraint are not equal to, like X1 != 2, in other words, the values in constraint can be equal to each other in that case
    return lambda do |known_vars, unknown_vars|
      s = Set.new
      if ne_val
        s.add(ne_val)
      else
        known_vars.each_value{|val|s.add(val)}
      end
      ret_val = {}
      unknown_vars.each{|key,value| ret_val[key] = value - s}
      
      return ret_val
    end
  end

  def handle_forward_check_eq(eq_val = nil)
    return lambda do |known_vars, unknown_vars|
      s = Set.new
      if eq_val
        s.add(eq_val)
      else
        s.add(known_vars.values[0])
      end
      ret_val = {}
      unknown_vars.each{|key, value| ret_val[key] = value.intersection(s);}
      
      return ret_val
    end
  end

end

class CSPRuleSet

  def initialize(proc_array = nil, any_proc = nil)
    @procs = {}
    proc_array.each{|proc| add_proc(proc[0],proc[1])} if proc_array
    set_any_proc(any_proc) if any_proc
  end
  
  def set_any_proc(proc)
    if proc.class == Proc
      @procs.default = proc
    else
      print "Error, trying to set default proc that isn't an executable object.\n"
    end
  end
  
  def add_proc(known_vars, proc)
    if proc.class == Proc || proc.class == CSPChainRule
      @procs[known_vars.collect{|val|val.to_s}.sort.inject(""){|string, var|string + "/" + var.to_s}] = proc
    else
      print "Error, trying to add a proc that that isn't an executable object.\n"
    end
  end
  
  def add_chain_rule(known_vars, var_rules)
    c = CSPChainRule.new(known_vars)
    var_rules.each{|rule| 
      rule_key = rule.collect{|val|val.to_s}.sort.inject(""){|string, var|string + "/" + var.to_s}
      c.add_proc(rule, @procs[rule_key])
    }
    add_proc(known_vars, c)
  end
  
  def forward_check(known_vars, unknown_vars)#known vars is a hash with the keys being the known variables and the values being their values, unknown vars is a hash with the key being the var name and the value being the domain as a set
    key = known_vars.keys.collect{|val|val.to_s}.sort.inject(""){|string, var|string + "/" + var.to_s}
    return @procs[key][known_vars, unknown_vars] if @procs[key]
    #print "couldn't find a fitting rule with this key #{key}, so returning {}\n"
    return {}
  end

end

class CSPChainRule
  
  def initialize(known_vars)
    @vars = known_vars
    @procs = []
  end
  
  def add_proc(var_subset, proc)
    if proc.class == Proc || proc.class == CSPChainRule
      @procs <<[var_subset, proc]
    else
      print "Error, trying to add a proc that that isn't an executable object.\n"
    end
  end
  
  def [](known_vars, unknown_vars)
    ret_val = {}
    @procs.each{|vars_and_proc|
      faked_known_vars = known_vars.dup
      faked_unknown_vars = unknown_vars.dup
      #print "using a chainrule\n"
      #print "Rule is expecting only #{vars_and_proc[0].inspect}.\n"
      (@vars.to_set - vars_and_proc[0].to_set).each{|var|
        faked_unknown_vars[var] = [known_vars[var]].to_set
        faked_known_vars.delete(var)
      }
      #print "using these known_vars #{faked_known_vars.inspect}\nand these unknown_vars #{faked_unknown_vars.inspect}\n"
      ret_val.update(vars_and_proc[1][faked_known_vars, faked_unknown_vars]){|key, oldval, newval| newval.intersection(oldval)}
    }
    @vars.each{|var|ret_val.delete(var)}
    return ret_val
  end
  
end


class CSPVar
  attr_reader :name, :vars
  
  def initialize(name)
    if name.class == Symbol || name.class == String
      @name = name.to_sym
      @vars = [@name]
    else
      print "Error, trying to set variable's name to something other than a string or symbol."
    end
  end
  
  def [](value)
    return value[0] if value.class == Array
    return value
  end

  def op(operator, rhs)
    if (rhs.class == CSPExpression || rhs.class == CSPVar)
      lhs_size = @vars.length
      return CSPExpression.new(self,lambda{|*x1| operator[self[x1[0]],rhs[*x1[1 .. -1]]]},rhs)
    else
      return CSPExpression.new(self,lambda{|x1| operator[self[x1],rhs]})
    end
  end
    
  def +(rhs)
    op(CSPExpression.plus, rhs)
  end
  
  def -(rhs)
    op(CSPExpression.minus, rhs)
  end
  
  def *(rhs)
    op(CSPExpression.times, rhs)
  end
  
  def /(rhs)
    op(CSPExpression.div, rhs)
  end

  def ==(rhs)
    if(rhs.class == CSPVar)
      c = CSPConstraint.new(@vars + rhs.vars)
      c.set_all_eq_constraint
      return c
    elsif rhs.class == CSPExpression
      express = op(CSPExpression.eql, rhs)
      return CSPConstraint.new(express.vars,express.action)
    else
      c = CSPConstraint.new(@vars)
      c.set_all_eq_constraint(rhs)
      return c
    end
  end

  def =~(rhs)
    if(rhs.class == CSPVar)
      c = CSPConstraint.new(@vars + rhs.vars)
      c.set_all_diff_constraint
      return c
    elsif rhs.class == CSPExpression
      express = op(CSPExpression.neql, rhs)
      return CSPConstraint.new(express.vars,express.action)
    else
      c = CSPConstraint.new(@vars)
      c.set_all_diff_constraint(rhs)
      return c
    end
  end

end

class CSPExpression
  attr_accessor :vars, :action
  def CSPExpression.plus
    lambda{|a,b| a + b}
  end
  def CSPExpression.minus
    lambda{|a, b| a - b}
  end
  def CSPExpression.times
    lambda{|a, b| a * b}
  end
  def CSPExpression.div
    lambda{|a, b| a / b}
  end
  def CSPExpression.eql
    lambda{|a,b| a == b}
  end
  def CSPExpression.neql
    lambda{|a,b| a != b}
  end
  def initialize(lhs, action = nil, rhs = nil)
    @vars = lhs.vars
    @vars += rhs.vars if rhs
    @lhs = lhs #lhs has to be either an expression or a variable
    @action = action
  end
  
  def op(operator, rhs)
    if (rhs.class == CSPExpression || rhs.class == CSPVar)
      lhs_size = @vars.length
      return CSPExpression.new(self,lambda{|*x1| operator[self[*x1[0 ... lhs_size]],rhs[*x1[lhs_size .. -1]]]},rhs)
    else
      return CSPExpression.new(self,lambda{|*x1| operator[self[*x1],rhs]})
    end
  end
  
  def +(rhs)
    op(CSPExpression.plus, rhs)
  end
  
  def -(rhs)
    op(CSPExpression.minus, rhs)
  end
  
  def *(rhs)
    op(CSPExpression.times, rhs)
  end
  
  def /(rhs)
    op(CSPExpression.div, rhs)
  end
  
  def =~(other)#!=
    express = op(CSPExpression.neql, other)
    return CSPConstraint.new(express.vars,express.action)
  end
  
  def ==(other)
    express = op(CSPExpression.eql, other)
    return CSPConstraint.new(express.vars,express.action)
  end
  
  def [](*value)
    return @action[*value] if @action
    return @lhs[*value]
  end
  
end