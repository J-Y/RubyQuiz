#!/usr/bin/ruby

$prec_tbl = {
  ['*', '+'] => true,
  ['*', '-'] => true,
  ['/', '+'] => true,
  ['/', '-'] => true,
  ['-', '-'] => true,
  ['/', '/'] => true,
  ['/', '*'] => true
}

def precede?(top, op)
  $prec_tbl[[top, op]]
end

def infix(arr, top = nil)
  throw "invalid postfix expression" unless !arr.empty?
  op = arr.pop
  if op =~ /\+|\-|\*|\//
    right = infix(arr, op)
    left = infix(arr, op)
    par = precede?(top, op)
    (par ? "(" : "") + "#{left} #{op} #{right}" + (par ? ")" : "")
  else
    op
  end
end

STDIN.each do |line|
  arr = line.split(/\s+/)
  begin
    res = infix(arr)
    throw "invalid postfix expression" unless arr.empty?
    puts "#{res} => #{eval(res)}"
  rescue
    STDERR.puts $!
  end
end
