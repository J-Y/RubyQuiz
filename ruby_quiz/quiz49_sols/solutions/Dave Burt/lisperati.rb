#!/usr/bin/ruby -W0
#
# Lisp Game
#
# A response to Ruby Quiz of the Week #49 [ruby-talk:158400]
#
# It's an implementation of the LISP game in the tutorial at
# http://www.lisperati.com/
#
# It's implemented by setting up a LISPy environment and copying the LISP code
# as closely as possible, using Ruby procs, arrays and strings.
#
# To play the game, fire up irb and require this file:
#
#   % irb
#   irb(main):001:0> require 'lisperati'
#
# A test script and walkthrough are accessible from the command-line:
#
#   % ruby lisperati.rb test
#   % ruby lisperati.rb walkthrough
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 1 Oct 2005
#
# Last modified: 5 Oct 2005
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is
#             not disallowed. Credit's appreciated if you use my code. I'd
#             appreciate seeing any modifications you make to it.

########################################################################
#
# Section 1 is a prelude to add some LISPiness to Ruby including LISP
# built-in functions.
#

class Array
  def inspect  # (JUST FOR FUN, MAKE ARRAYS LOOK LIKE LISP LISTS)
    '(' + map{|x| x.upcase }.join(" ") + ')'
  end
end

module Lisp

  def f(&block)
    block
  end

  # helper for functions returning lists of words
  def fw(&block)
    f{block.call.split}
  end

  def setf
    f{|variable, value|
      raise ArgumentError.new("setf needs a variable name and a value.") \
        unless variable
      $_ = value
      if variable[0] == ?$
        eval "#{variable} = $_"
      else
        Lisp.module_eval "attr_accessor :#{variable}"
        self.instance_eval "@#{variable} = $_"
      end }
  end

  alias defun setf # Skip function params - use Ruby's block parameter syntax
                   # defun['function_name', f{|params| function body }]
                   # (Could be done like let instead)

  # Instead of macros, we have a post-processing way to turn something that
  # looks like a method call into a string.
  def method_missing(meth, *args)
    "#{meth}#{' ' + args.map{|a| a.to_s }.join(', ') unless args.empty?}"
  end
end

include Lisp

# This is a guess at LISP's let semantics; I don't know LISP scoping
defun['let', f{|mapping, block|
  saved_values = {}
  mapping.each do |variable, value|
    saved_values[variable] = self.instance_eval(variable.to_s) rescue nil
    $_ = value
    self.instance_eval "setf['#{variable}', $_]"
  end
  ret = block[]
  saved_values.each_pair do |variable, value|
    $_ = value
    self.instance_eval "setf['#{variable}', $_]"
  end
  ret
}]

setf['t', true]

defun['assoc', f{|key, mapping|
  mapping.find {|rec| rec[0] == key } }]

defun['first', f{|list|
  list[0] }]

defun['second', f{|list|
  list[1] }]

defun['third', f{|list|
  list[2] }]

defun['apply', f{|func, list|
  func[*list] }]

defun['eq', f{|a, b|
  a == b }]

defun['append', f{|*list|
  list.inject([]) {|memo, obj| memo + obj } }]

defun['car', f{|list|
  list[0] }]

defun['cdr', f{|list|
  list[1..-1] }]

defun['cddr', f{|list|
  cdr[cdr[list]] }]

defun['mapcar', f{|func, list|
  list.map &func }]

defun['remove_if_not', f{|func, list|
  list.find_all &func }]

defun['cond', f{|*cases|
  cases.each {|condition, *actions|
    if condition
      ret = nil
      actions.each {|action| ret = action.call }
      break ret
    end }}]

defun['push', f{|item, list|
  list.unshift item }]

defun['pop', f{|list|
  list.shift }]

defun['list', f{|*args|
  args }]

defun['member', f{|item, list|
  list.include? item }]

defun['and_', f{|*args|
  args.all? }]

defun['not_', f{|arg|
  not arg || arg == [] }]

########################################################################
#
# Section 2 is the game definition.
#

setf['$objects', %w[whiskey_bottle bucket frog chain]]

setf['$map', [['living_room', %w[you are in the living_room of a wizards house.
                                 there is a wizard snoring loudly on the couch.],
                              %w[west door garden],
                              %w[upstairs stairway attic]],
        ['garden', %w[you are in a beautiful garden. there is a well in front
                      of you.],
                   %w[east door living_room]],
        ['attic', %w[you are in the attic of the wizards house. there is a
                     giant welding torch in the corner.],
                  %w[downstairs stairway living_room]]]]

setf['$object_locations', [%w[whiskey_bottle living_room],
                           %w[bucket living_room],
                           %w[chain garden],
                           %w[frog garden]]]

setf['$location', 'living_room']

defun['describe_location', f{|location, map|
  second[assoc[location, map]] }]

defun['describe_path', f{|path|
  ['there','is','a',second[path],'going',first[path],'from','here.'] }]

defun['describe_paths', f{|location, map|
  apply[append, mapcar[describe_path, cddr[assoc[location, map]]]] }]

defun['is_at', f{|obj, loc, obj_loc|
  eq[second[assoc[obj, obj_loc]], loc] }]

defun['describe_floor', f{|loc, objs, obj_loc|
  apply[append, mapcar[lambda{|x|
                         ['you','see','a',x,'on','the','floor.'] },
                       remove_if_not[lambda{|x|
                                       is_at[x, loc, obj_loc] },
                                     objs]]] }]

defun['look', f{
  append[describe_location[$location, $map],
         describe_paths[$location, $map],
         describe_floor[$location, $objects, $object_locations]] }]

defun['walk_direction', f{|direction|
  let[ [['next_', assoc[direction, cddr[assoc[$location, $map]]]]],
    f{
      cond[[next_, f{setf['$location', third[next_]]}, look],
        [t, fw{"you cant go that way."}]] }] }]

# I don't know how LISP macros work, so I'm cheating here.

def walk(*args) walk_direction[*args] end

defun['pickup_object', f{|object|
  cond[[is_at[object, $location, $object_locations],
        f{push[list[object, 'body'], $object_locations]},
        f{['you','are','now','carrying','the',object]}],
       [t,
        fw{"you cannot get that."}] ] }]

def pickup(*args) pickup_object[*args] end

defun['inventory', f{
  remove_if_not[lambda{|x|
                  is_at[x, 'body', $object_locations] },
                $objects] }]

defun['have', f{|object|
  member[object, inventory[]] }]

setf['$chain_welded', nil]

defun['weld', f{|subject, object|  # Actually, it's a direct object and an
                                   # indirect object.
  cond[[and_[eq[$location, 'attic'],
             eq[subject, 'chain'],
             eq[object, 'bucket'],
             have['chain'],
             have['bucket'],
             not_[$chain_welded]],
        f{setf['$chain_welded', 't']},  # I think this 't' should properly be t
        fw{"the chain is now securely welded to the bucket."}],
       [t, fw{"you cannot weld like that."}]] }]

setf['$bucket_filled', nil]

defun['dunk', f{|subject, object|  # Another direct/indirect object pair.
  cond[[and_[eq[$location, 'garden'],
             eq[subject, 'bucket'],
             eq[object, 'well'],
             have['bucket'],
             $chain_welded],
        f{setf['$chain_welded', 't']}, fw{"the bucket is now full of water."}],
       [t, fw{"you cannot weld like that."}]] }]

# That SPEL is crazy. Let's do it Rubyishly.
def game_action(command, subj, obj, place, rest)
  setf["__#{command}_rest", rest]
  Lisp.module_eval "
    def #{command}(subject, object=nil)
      if object.nil?
        subject, object = subject.split
      end
      cond[[and_[eq[$location, #{place.inspect}],
                 eq[subject, #{subj.inspect}],
                 eq[object, #{obj.inspect}],
                 have[#{subj.inspect}]],
            __#{command}_rest],
           [t, f{%w[i cant #{command} like that.]}]]
    end"
end

# weld and dunk redefined

game_action "weld", chain, bucket, attic, f{
  cond[[and_[have['bucket'], setf['$chain_welded', 't']],
        fw{"the chain is now securely welded to the bucket"}],
       [t, fw{"you do not have a bucket."}]] }

game_action "dunk", bucket, well, garden, f{
  cond[[$chain_welded,
        f{setf['$bucket_filled', 't']},
        fw{"the bucket is now full of water"}],
       [t, fw{"you do not have a bucket."}]] }

game_action splash, bucket, wizard, living_room, f{
  cond[[not_[$bucket_filled], fw{"the bucket has nothing in it."}],
       [have_['frog'], fw{"the wizard awakens and sees that you stole his frog.
                           he is so upset he banishes you to the 
                           netherworlds- you lose! the end."}],
       [t, fw{"the wizard awakens from his slumber and greets you warmly. 
               he hands you the magic low-carb donut- you win! the end."}]] }


########################################################################
#
# Section 3 defines the behaviour of the script:
#  - as a library, start by printing the output of look
#  - called from the command-line, runs a walkthrough script
#

if $0 == __FILE__

  commands = case ARGV[0]
  when 'test'
    <<-END
    describe_location['living_room', $map]
    describe_path[%w[west door garden]]
    describe_paths['living_room', $map]
    is_at['whiskey_bottle', 'living_room', $object_locations]
    describe_floor['living_room', $objects, $object_locations]
    look[]
    walk_direction['west']
    walk east
    pickup whiskey_bottle
    inventory[]
    have['whiskey_bottle']
    weld['chain', 'bucket']
    weld[chain, bucket]
    END
  when 'walkthrough'
    <<-END
    look[]
    pickup bucket
    walk west
    pickup chain
    walk east
    walk upstairs
    inventory[]
    weld chain bucket
    walk downstairs
    walk west
    dunk bucket well
    walk east
    splash bucket wizard
    END
  else
    puts "usage #$0 [test|walkthrough]\n or require in irb for interactive mode"
    exit
  end

  commands.each_line do |line|
    print "> ", line
    p eval(line)
  end

else

  p look[]

end
