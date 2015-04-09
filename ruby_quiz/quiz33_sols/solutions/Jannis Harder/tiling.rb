class Board
  def initialize(size,x,y)
    raise unless self.logcheck(size)
    @size = size
    @x,@y = x,y
    clear
  end
  SUBDIV = [[:bottom_left,2,0],[:top_left,1,1],[:top_left,2,2],[:top_right,0,2]]
  TRANSFORM_O = {
    :top_left => {
      :top_left => :top_left,
      :top_right => :top_right,
      :bottom_right => :bottom_right,
      :bottom_left => :bottom_left
    },
    :top_right => {
      :top_left => :top_right,
      :top_right => :bottom_right,
      :bottom_right => :bottom_left,
      :bottom_left => :top_left
    },
    :bottom_right => {
      :top_left => :bottom_right,
      :top_right => :bottom_left,
      :bottom_right => :top_left,
      :bottom_left => :top_right
    },
    :bottom_left => {
      :top_left => :bottom_left,
      :top_right => :top_left,
      :bottom_right => :top_right,
      :bottom_left => :bottom_right
    }
  }
  TRANSFORM_C = {
    :top_left => Proc.new{|x,y|[x,y]},
    :top_right => Proc.new{|x,y|[2-y,x]},
    :bottom_right => Proc.new{|x,y|[2-x,2-y]},
    :bottom_left => Proc.new{|x,y|[y,2-x]}
  }
  
  def add_l_tromino(x,y,size,orientation)
    if size == 1
      case orientation
      when :top_left
        self[x+1,y  ,true] = :top_left_a
        self[x  ,y+1,true] = :top_left_b
        self[x+1,y+1,true] = :top_left_c
      when :top_right
        self[x  ,y  ,true] = :top_right_a
        self[x  ,y+1,true] = :top_right_b
        self[x+1,y+1,true] = :top_right_c
      when :bottom_left
        self[x  ,y  ,true] = :bottom_left_a
        self[x+1,y  ,true] = :bottom_left_b
        self[x+1,y+1,true] = :bottom_left_c
      when :bottom_right
        self[x  ,y  ,true] = :bottom_right_a
        self[x+1,y  ,true] = :bottom_right_b
        self[x  ,y+1,true] = :bottom_right_c
      else
        raise
      end
    elsif size > 1
      ns = size/2
      SUBDIV.each do |subl|
        no,nx,ny = subl
        nx,ny = TRANSFORM_C[orientation][nx,ny]
        nx,ny = nx*ns,ny*ns
        no = TRANSFORM_O[orientation][no]
        self.add_l_tromino(x+nx,y+ny,ns,no)
      end
    end
    nil
  end
  HTML_HEAD =
'<html>
  <head>
    <title>Ruby Quiz #33</title>
    <style>
      tr{padding:0;margin:0;}
      td{font-size:2px;width:9px;height:9px;margin:0;padding:0}
      .nil{border: 1px solid #777}
      .tla{border-top:solid 1px #000;border-right:solid 1px #000;border-left:solid 1px #000;background:#E00}
      .tlb{border-top:solid 1px #000;border-bottom:solid 1px #000;border-left:solid 1px #000;background:#E00}
      .tlc{border-bottom:solid 1px #000;border-right:solid 1px #000 ;background:#E00}
      .tra{border-top:solid 1px #000;border-right:solid 1px #000;border-left:solid 1px #000;background:#090}
      .trb{border-bottom:solid 1px #000;border-left:solid 1px #000;background:#090}
      .trc{border-top:solid 1px #000;border-right:solid 1px #000;border-bottom:solid 1px #000;background:#090}
      .bra{border-top:solid 1px #000;border-left:solid 1px #000;background:#00F}
      .brb{border-bottom:solid 1px #000;border-top:solid 1px #000;border-right:solid 1px #000;background:#00F}
      .brc{border-left:solid 1px #000;border-right:solid 1px #000;border-bottom:solid 1px #000;background:#00F}
      .bla{border-top:solid 1px #000;border-left:solid 1px #000;border-bottom:solid 1px;background:#EC0}
      .blb{border-top:solid 1px #000;border-right:solid 1px #000;background:#EC0}
      .blc{border-left:solid 1px #000;border-right:solid 1px #000;border-bottom:solid 1px #000;background:#EC0}
      
      .missing{background:#000}
    </style>
  </head>
  <body>
    <table cellspacing="0">'
  S_ORI = [[:top_left,:bottom_left],[:top_right,:bottom_right]]
  def solve(from=1,to=@size>>1)
    tx,ty = @x,@y
    s = from
    tx/=from
    ty/=from
    raise unless self.logcheck(from) and self.logcheck(to)
    while s<=to
      dx,dy = tx & 1, ty &1
      tx,ty = tx >>1, ty>>1
      
      self.add_l_tromino(tx*(s<<1),ty*(s<<1),s,S_ORI[dx][dy]) 
      s<<=1
    end
    self
  end
  

  def to_html
    out = HTML_HEAD.dup
    (0..@size-1).each do |y|
      out << '<tr>'
      (0..@size-1).each do |x|
        e = self[x,y]
        out << "<td class=\"#{e ? e.to_s.gsub(/([^_])[^_]*_/,'\1') : 'nil'}\">&nbsp;</td>"
      end
      out << '</tr>'
    end
    out << '</table></body></html>'
  end
  def clear
    @data =(1..@size).map{[nil]*@size}
    self[@x,@y] = :missing
    nil
  end
  
  def show
    File.open("/tmp/tiling.html","w") do |f|
      f.puts self.to_html
    end
    `open /tmp/tiling.html`
  end
  
  def [](x,y)
    @data[x][y]
  end
  def []=(x,y,v,q=false)
    if q == false
      @data[x][y] = v
    elsif @data[x][y] == nil 
      @data[x][y] = q
    else
      raise
    end
  end
protected
  def logcheck(n)
    ("%b" % n).tr("0","") == "1"
  end
end

if __FILE__ == $0
  def logcheck(n)
    ("%b" % n).tr("0","") == "1"
  end
  size = nil
  until size
    STDERR.print "Size?: "
    STDERR.flush
    e = STDIN.gets
    u=Integer(e) rescue nil
    size = u if logcheck(u)
  end
  x = nil
  until x
    STDERR.print "X?: "
    STDERR.flush
    e = STDIN.gets
    u=Integer(e) rescue nil
    x = u if (u)<size and u >= 0 
  end
  y = nil
  until y
    STDERR.print "Y?: "
    STDERR.flush
    e = STDIN.gets
    u=Integer(e) rescue nil
    y = u if (u)<size and u >= 0 
  end
  puts Board.new(size,x,y).solve.to_html
end


