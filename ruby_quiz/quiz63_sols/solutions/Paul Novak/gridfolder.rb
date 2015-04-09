def fold folds, rows = 16, cols = 16
  validate folds, rows, cols
  grid = Grid.new(rows, cols)
  folds.scan(/./){|op|grid.send(op)}
  return grid.list_values
end

def validate folds, rows, cols
  lr_folds = folds.count("LR")
  tb_folds = folds.count("TB")
  while rows>1
    rows/=2.0
    tb_folds-=1
  end
  while cols>1
    cols/=2.0
    lr_folds-=1
  end
  if rows!=1.0 or cols!=1.0 or tb_folds!=0 or lr_folds!=0
    fail "invalid fold instructions"
  end 
end

class Grid
  attr_reader :face_rows, :face_cols
  def initialize (row_count, col_count)
    # set up array of arrays of Cells that can be transposed between rows or columns
    @face_rows = Array.new(row_count) { |i|
     ((i*col_count+1)..((i+1)*col_count)).map{|v|Cell.new(v)}}.map{|r|r.to_a}
    @face_cols = @face_rows.transpose # this is just too easy
  end  
  ## L,R,T,B could probably be refactored into one method, but this works...
  def L
    new_face = []
    @face_rows.each do |a|
      new_row=[]
      while c2 = a.pop
        c1 = a.shift
        new_row << c1.get_chain[-1]
        c1.link_to c2
        c2.link_to c1
      end
      new_face << new_row.reverse  # since folding flips it over
    end
    @face_rows = new_face
    @face_cols = @face_rows.transpose
  end
  def R
    new_face = []
    @face_rows.each do |a|
      new_row = []
      while c2 = a.pop
        c1 = a.shift
        new_row << c2.get_chain[-1]
        c1.link_to c2
        c2.link_to c1
      end
      new_face << new_row
    end
    @face_rows = new_face
    @face_cols = @face_rows.transpose
  end
  def T
    new_face = []
    @face_cols.each do |a|
      new_col=[]
      while c2 = a.pop
        c1 = a.shift
        new_col << c1.get_chain[-1]
        c1.link_to c2
        c2.link_to c1
      end
      new_face << new_col.reverse  # since folding flips it over
    end
    @face_cols = new_face
    @face_rows = @face_cols.transpose
  end
  def B
    new_face = []
    @face_cols.each do |a|
      new_col=[]
      while c2 = a.pop
        c1 = a.shift
        new_col << c2.get_chain[-1]
        c1.link_to c2
        c2.link_to c1
      end
      new_face << new_col
    end
    @face_cols = new_face
    @face_rows = @face_cols.transpose 
  end
  
  def list_values
    @face_rows.flatten.first.get_chain.map{|x|x.value}
  end
end

class Cell
  
  attr_reader :links, :value
  def initialize value
    @value = value
    @links = []
  end
  def link_to c
    @links << c
  end
  def get_chain start_cell=self
    next_cell = @links.reject{|x|x==start_cell}.last
    next_cell ? [self] + next_cell.get_chain(self) : [self]
  end
  def inspect
    @value
  end
end














