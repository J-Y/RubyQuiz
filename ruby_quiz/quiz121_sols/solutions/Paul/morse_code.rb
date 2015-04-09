#!/usr/bin/ruby
# a lazy way to convert pasted-on text from problem into a Hash

$morse = Hash[*%w{
        A .-            N -.
        B -...          O ---
        C -.-.          P .--.
        D -..           Q --.-
        E .             R .-.
        F ..-.          S ...
        G --.           T -
        H ....          U ..-
        I ..            V ...-
        J .---          W .--
        K -.-           X -..-
        L .-..          Y -.--
        M --            Z --.. }]

# convert dashes and dots to regexen to match each code at beginning of line
# gotta love it when Ruby let's you convert documentation to code!
$morse.each_pair { |k,v|  $morse[k] = Regexp.new("^(%s)(.*)" % Regexp.escape(v))}

def parse(code, parsed_so_far)
  if code==""
    p parsed_so_far
  else
    $morse.each_pair do |k,v|
      m = v.match( code).to_a
      if m.length>0
        parse(m[2], parsed_so_far + k)
      end
    end
  end
end

parse(ARGV[0],"")
