#!/usr/bin/env ruby -w

STDOUT.sync = true

# $qtree is the root of a tree where non-leaf nodes are 3-element arrays.
# The first element of a non-leaf node is a question.  The second
# and third elements are nodes.  The second element corresponds
# to a "yes" answer for the question, and the third element corresponds
# to a "no" answer for the question.  A leaf node is a 1-element array
# that contains an animal name.  The initial node for $qtree is a leaf
# node for the animal "human".

$qtree = [ "human" ]

# $current_node, $parent_node, and $parent_branch maintain our current
# position while navigating down the tree.  Except when $parent_node
# is nil, $parent_node[$parent_branch] == $current_node.

$current_node = $parent_node = $parent_branch = nil

def main
  $log = File.open("animal-log.txt", "a+")
  # Replay all previous sessions from the logfile to initialize $qtree.
  read_from($log) until $log.eof
  # Play interactively.
  read_from(STDIN)
  $log.close
end

def read_from(i)
  $istream = i
  $replay = ($istream != STDIN)
  loop do
    prompt "Would you like to play a game? "
    if get_answer.downcase[0] == ?y
      prompt "Please think of an animal...\n\n"
      play
    else
      prompt "Good bye.\n"
      break
    end
  end
end

# Print a prompt unless we are in replay mode.
def prompt(str)
  print str unless $replay
end

# Get an answer and log it unless we are in replay mode.
def get_answer
  input = $istream.gets.chomp
  $log.puts(input) unless $replay
  input
end

# Play a round of the game
def play
  # Reset pointers to top of $qtree.
  $parent_node = $parent_branch = nil
  $current_node = $qtree
  # Keep guessing until we're done.
  while guess; end
end

def guess
  question = $current_node.length == 1 ?
    "Is your animal \"" + $current_node[0] + "\"? " :
    $current_node[0]
  prompt question
  answer = get_answer.downcase[0]

  if $current_node.length == 1
    if answer == ?y
      prompt "I win!\n\n"
    else
      learn
    end
    return false
  else
    $parent_node = $current_node
    $parent_branch = (answer == ?y) ? 1 : 2
    $current_node = $parent_node[$parent_branch]
    return true
  end
end

def learn
  last_animal = $current_node[0]
  prompt "I give up.  What is your animal? "
  animal = get_answer
  prompt "What question distinguishes \"#{last_animal}\" from \"#{animal}\"?\n"
  question = get_answer
  # Adjust the punctuation at the end of the question.
  question.sub!(/\??\s*$/, '? ')
  prompt "What is the answer to this question for \"#{animal}\"? "
  yes = (get_answer.downcase[0] == ?y)
  prompt "Thank you.\n\n"

  # Build a new node refering to $current_node,
  # then insert it into the location of $current_node.
  node = yes ?
    [ question, [animal], $current_node ] :
    [ question, $current_node, [animal] ]
  if $parent_node == nil
    $qtree = node
  else
    $parent_node[$parent_branch] = node
  end
end

main
