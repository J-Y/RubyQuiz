require 'CSP'

def variables(*array)
  $__csp = CSP.new
  $__rules = {}
  eval_string = ""
  array.each{|value| $__csp.add_var(value[0].to_s,value[1]);eval_string += "$#{value[0]}=CSPVar.new(\"#{value[0].to_s}\");"}
  eval eval_string
end

def constraint(csp_constraint, rule = nil)
  csp_constraint.set_rule_set($__rules[rule.to_sym]) if rule
  $__csp.add_constraint(csp_constraint)
end

def func_constraint(var, func = nil, rule = nil, &proc)
  if proc
    rule = func
    func = proc
  end
  var.map! {|item|item.to_s}
  c = CSPConstraint.new(var,func)
  c.set_rule_set($__rules[rule.to_sym]) if rule
  $__csp.add_constraint(c)
end

def create_ruleset(name)
  $__rules[name.to_sym] = CSPRuleSet.new
end

def add_rule(name, vars, func=nil, &proc)
  func = proc if proc
  $__rules[name.to_sym].add_proc(vars, func)
end

def add_chain_rule(name, vars, *var_rules)
  $__rules[name.to_sym].add_chain_rule(vars, var_rules)
end

def set_default_rule(name, func=nil, &proc)
  func = proc if proc
  $__rules[name.to_sym].set_any_proc(func)
end

def print_csp
  print $__csp.inspect
end

def all_diff_constraint(*vars)
  vars.map! {|item|item.to_s}
  c = CSPConstraint.new(vars)
  c.set_all_diff_constraint
  $__csp.add_constraint(c)
end

def all_eq_constraint(*vars)
  vars.map!{|item|item.to_s}
  c = CSPConstraint.new(vars)
  c.set_all_eq_constraint
  $__csp.add_constraint(c)
end

def solve
  answer = $__csp.run
end

def clear
  $__csp = nil;
end

def debug
  $__csp.debug = true
end