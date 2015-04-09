# The Kalotans are a tribe with a peculiar quirk.  Their males always
# tell the truth. Their females never make two consecutive true
# statements, or two consecutive untrue statements.
#
# An anthropologist (let's call him Worf) has begun to study
# them. Worf does not yet know the Kalotan language. One day, he meets
# a Kalotan (heterosexual) couple and their child Kibi. Worf asks
# Kibi: ``Are you a boy?'' Kibi answers in Kalotan, which of course
# Worf doesn't understand.
#
# Worf turns to the parents (who know English) for explanation. One of
# them says: ``Kibi said: `I am a boy.' '' The other adds: ``Kibi is a
# girl. Kibi lied.''
#
# Solve for the sex of the parents and Kibi.

require 'amb'

# Some helper methods for logic
class Object
  def implies(bool)
    self ? bool : true
  end
  def xor(bool)
    self ? !bool : bool
  end
end

count = 0
A = Amb.new

# Begin the solution

begin
  # Kibi's parents are either male or female, but must be distinct.

  parent1 = A.choose(:male, :female)
  parent2 = A.choose(:male, :female)
  A.assert parent1 != parent2

  # Kibi sex, and Kibi's self description are separate facts

  kibi = A.choose(:male, :female)
  kibi_said = A.choose(:male, :female)

  # We will capture whether kibi lied in a local variable.  This will
  # make some later logic conditions a bit easier.  (Note: the Scheme
  # implementation sets the kibi_lied variable to a choice of true or
  # false and then uses assertions to make all three variables
  # consistent.  This way however, is just so much easier.)

  kibi_lied = kibi != kibi_said

  # Now we look at what the parents said.  If the first parent was
  # male, then kibi must have described itself as male.

  A.assert(
    (parent1==:male).implies( (kibi_said == :male ) )
    )

  # If the first parent is female, then there are no futher deductions
  # to make.  Their statement could either be true or false.

  # If the second parent is male, then both its statements must be
  # true.

  A.assert( (parent2 == :male).implies( kibi==:female ))
  A.assert( (parent2 == :male).implies( kibi_lied ))

  # If the second parent is female, then the condition is more
  # complex.  In this case, one or the other of the parent 2's
  # statements are false, but not both are false.  Let's introduce
  # some variables for statements 1 and 2 just to make this a bit
  # clearer.

  s1 = kibi_lied
  s2 = (kibi == :female)

  A.assert(
    (parent2 == :female).implies( (s1 && !s2).xor(!s1 && s2) )
    )

  # Now just print out the solution.

  count += 1
  puts "Solution #{count}"
  puts "The first parent is #{parent1}."
  puts "The second parent is #{parent2}."
  puts "Kibi is #{kibi}."
  puts "Kibi said #{kibi_said} and #{kibi_lied ? 'lied' : 'told the truth'}."
  puts

  A.failure # Force a search for another solution.

rescue Amb::ExhaustedError
  puts "No More Solutions"
end
