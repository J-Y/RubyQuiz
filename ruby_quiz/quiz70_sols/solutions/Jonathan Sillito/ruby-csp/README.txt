AI::CSP is a library for modeling and solving constraint satisfaction
problems (CSPs) implemented in pure ruby. 

The library is written and maintained by Jonathan Sillito. Please
report bugs, make suggestions or otherwise get involved by email at
sillito@gmail.com.

INSTALLATION

Unpack the tgz or zip in some directory and cd to that directory. If
you are so inclined you can run the tests or the examples as follows:

    > ruby tests/csp-all-tests.rb
    > ruby tests/csp-performance.rb
    > ruby examples/queens.rb
    > ruby examples/golomb.rb
    > ruby examples/magicsquare.rb

To install the library simply copy the 'ai' directory to your
'site_ruby' directory (which might require super user privilege). On
my Mac OS X box this looks like:

    > cp -R ai /usr/lib/ruby/site_ruby/

Alternatively you can copy the ai directory to any directory specified
in your $RUBYLIB environment variable.

DOCUMENTATION

See doc/index.html for library documentation. Also there are a few
moderately involved examples in the examples directory of this
distribution.
