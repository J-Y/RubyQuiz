This is NOT my quiz entry - I started with Antlr, but soon realised
it could be done _much_ more easily in plain Ruby. I did carry on
with Antlr v3 with the new Ruby back-end, because Antlr/R has been on
my radar for a while and I wanted to try it out. It's a very simple
parser that doesn't use ASTs or anything, and is basically a lot of
rule hacks around a stack. But it (almost) works. 

Although the grammar is included, I also chose to include the parser
and lexer generated from it, since I guess not everyone will have the
latest Antlr v3 ea release. The Ruby Antlr runtime is also included
(antlr.rb). 

The most difficult thing with this was treating the '%' correctly,
and though I crashed around with a few ideas I didn't manage to 
get it working properly. I had to revert a few times before finally
giving up on having it perfect - maybe I'll keep playing with it :) 
It works fine, but fails to barf properly on bad input (e.g. 55%), 
so can't be considered a correct parser I guess. The same applies 
ith using the arithmetic operators as unary operators at the beginning
of the string - it fails, but only because of a Ruby nil exception.

In addition there are a few things that I just couldn't figure out
how to translate from Antlr V2 to V3, like handling syntax errors 
cleanly in the lexer and stuff.

Antlr v3 is still in development, and the Ruby back-end is still new.
Worse, this is the first play with v3 I've had (wow, it's different)
and I'm certainly no Grammarian, but enjoyed playing with Antlr before
and I've been dying to try the Ruby version. With the shortcomings
I mentioned I'm not sure it's a correct quiz solution but it was
fun coding it up :)

But anyway, enough about that...

== GET IT GOING ALREADY!

To execute an expression, just run roll.rb:

  ruby roll.rb <expr> [count = 1]

Where expr follows the format shown in the Quiz, and count is 
optional. This will print a list of results for each run of the
expression.

If you want to watch every single move (maybe your computer is using
loaded dice, huh?) then just add a quick 'verbose':

  ruby --verbose roll.rb <expr> [count = 1]

Notice it's a param to Ruby, not roll.rb. 

There's also a small test that's really just checking the precedence
rules and what have you. To run that, fire up 'test.rb'.

You don't need to have Antlr lying around for this to work, since
the generated parser and Antlr runtime are included here. 

== FIDDLING ABOUT WITH THE GRAMMAR

If you want to remake the grammar, get the relevant Antlr installed,
then just do:

  antlr dice.g

Actually, you'll probably have to write a shell script or something first
to start Java, or else replace 'antlr' with a bit of of 'java -cp' to start
it up yourself, but you get the idea...

You will get a warning, but since it's coming from the Ruby code triggering
a warning about Antlr syntax, it can be safely ignored. I guess there is
probably some way to escape this stuff but I didn't really look... 

You can see the BNF for the grammar with something like:

  antlr -print dice.g

Anyway, get bits from:

  Antlr v3 ea7 : http://www.antlr.org/download/antlr-3.0ea7.tar.gz
  Antlr Runtime: http://clans.gameclubcentral.com/shoot/antlr.rb

== THANKS

The general form for the grammar is based on a simple arithmetic expression
language grammar that serves as an example for Antlr Ruby:

  http://split-s.blogspot.com/2005/12/antlr-for-ruby.html


