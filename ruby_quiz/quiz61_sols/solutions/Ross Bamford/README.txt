This is my quiz entry for Ruby Quiz 61 (Dice Roller). It's actually the
second idea I had, after starting out with Antlr (I still finished that
one, because I wanted to get to grips with Antlr anyway). I've bundled
it up along with this entry at:

  http://roscopeco.co.uk/code/ruby-quiz-entries/quiz61-dice-roller.tar.gz

Anyway, back to my real entry. I guess I took the short-cut route to
the dice-roller, and instead of parsing out the expressions I instead
decided to 'coerce' them to Ruby code, by just implementing the 'd' 
operator with a 'rolls' method on Fixnum, and using gsub to convert
the input expression.

  d3*2                  =>   1.rolls(3)*2
  (5d5-4)d(16/d4)+3     =>   (5.rolls(5)-4).rolls(16/1.rolls(4))+3
  d%*7                  =>   1.rolls(100)*7 

This is implemented in the DiceRoller.parse method, which returns the
string. You can just 'eval' this of course, or use the 'roll' method
(also provided as a more convenient class method that wraps the whole
thing up for you) to do it. Ruby runs the expression, and gives back
the result. I almost feel like I cheated...?

As well as the main 'roll.rb' I also included a separate utility that
uses loaded dice to find min/max achievable.

== GET IT GOING ALREADY!

To execute an expression, just run roll.rb:

  ruby roll.rb <expr> [count = 1]

Where expr follows the format shown in the Quiz, and count is 
optional. This will print a list of results for each run of the
expression.

If you want to watch every single move (maybe your computer is trying
to cheat with loaded dice, huh?) then just add a quick 'verbose':

  ruby --verbose roll.rb <expr> [count = 1]

Notice it's a param to Ruby, not roll.rb. 

To find min/max for a given expression, just run:

  ruby minmax.rb <expr> [count - 1]

The same applies with verbose here.

There's also a small test that's really just checking the precedence
rules and what have you. To run that, fire up 'test.rb'. This actually
sets up VERBOSE itself.

