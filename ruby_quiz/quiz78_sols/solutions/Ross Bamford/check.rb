#!/usr/local/bin/ruby
def check_parens(s, parens = '()[]{}')
  stack = []
  s = s.gsub(/\\[#{Regexp.escape(parens)}]/, '')
  s.split(//).each_with_index do |c,i|
    if tp = parens.index(c)
      if tp == (pg_start = (tp / 2) * 2)
        # opening paren
        stack << [c,i]
      else
        # closing paren
        if (stack.last || []).first == parens[pg_start,1]
          stack.pop
        else
          stack << [c,i]
          break
        end
      end
    end
  end
  stack
end

def balanced_and_valid?(s, parens = '()[]{}')
  !!if check_parens(s,parens).empty?
    rx = /#{parens.scan(/../).map { |e| Regexp.escape(e) }.join('|')}/
    true unless s =~ rx
  end
end

if $0 == __FILE__
  raise ArgumentError, 'No input', [] unless brackets = ARGV.first
  exit(balanced_and_valid?(brackets) ? 0 : 1)
end
