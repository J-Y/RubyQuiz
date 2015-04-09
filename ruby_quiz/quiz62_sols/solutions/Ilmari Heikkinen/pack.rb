class Array
  def delete_first item
    delete_at index(item)
  end

  def rotate
    d = dup
    d.push d.shift
    d
  end
end

class Trunk
  def initialize(w,h)
    @w = w
    @h = h
    @items = []
    @rows = (1..@h+2).map{ "_"*(@w+2) }
  end

  def add box
    try_adding(box) or try_adding(box.rotate)
  end

  def try_adding box
    boxrow = "_"*(box[0]+2)
    @rows.each_with_index{|r,i|
      break if i > @rows.size - (box[1]+2)
      next unless r.include?(boxrow)
      idxs = @rows[i+1, box[1]+1].map{|s| s.index boxrow }
      next unless idxs.all?
      idx = idxs.max
      next unless @rows[i, box[1]+2].all?{|s| s[idx,boxrow.size] == boxrow }
      @rows[i+1, box[1]].each{|s|
        s[idx+1, box[0]] = "#" * box[0]
      }
      @items.push box
      return box
    }
    nil
  end

  def empty?
    @items.empty?
  end

  def to_s
    @rows[1..-2].map{|r|r[1..-2]}.join("\n")
  end
end

trunk = gets.strip.split("x").map{|i| i.to_i}
boxes = gets.strip.split(" ").map{|s| s.split("x").map{|i| i.to_i} }

boxes = boxes.sort_by{|b| b.inject{|f,i| f*i} }.reverse
trunks = [Trunk.new(*trunk)]
until boxes.empty?
  fitting = boxes.find{|box| trunks.last.add box }
  if fitting
    boxes.delete_first fitting
  elsif trunks.last.empty?
    raise "Can't fit #{boxes.inspect} into the trunk"
  else
    trunks << Trunk.new(*trunk) unless boxes.empty?
  end
end
puts
puts trunks.join("\n\n")
