module Enumerable
  def abbr
    map do |word|
      word = word.to_s
      word.split('').inject([]) do |s,v|
        s << [s.last,v].join
      end.inject({}) do |s,v|
        s.merge(v => word)
      end
    end
  end
end

class Object
  ABBREVS = Hash.new{|h,k| h[k] = []}
  def abbrev(*args)
    ABBREVS.merge!(self => ABBREVS[self].push(*args.abbr))
    ABBREVS[self].uniq!
  end

  def method_missing meth, *args, &block
    possible = ABBREVS[self.class].select{|a| a[meth.to_s]}.map{|h| h.values.first.to_sym}
    p meth => possible
    if possible.size == 1
      if (method(possible.first) rescue false)
        send(possible.first, *args, &block)
      else
        super
      end
    elsif possible.size > 1
      real = possible.select{|m| (method(m) rescue false)}
      if real.empty?
        super
      else
        real
      end
    else
      super
    end
  end
end