class FoldedPaper
  attr_reader :xlength,:ylength,:thickness
  attr_accessor :sheets
  
  @@dict = {'B' => 0, 'R' => 1, 'T' => 2, 'L' => 3}
  @@rev_dict = {0 => 'B', 1 => 'R', 2 => 'T', 3 => 'L'}
  
  def initialize(x,y,thickness = 1)
    @xlength = x
    @ylength = y
    @thickness = thickness
    @sheets = Array.new(thickness)
    @sheets.each_index do |i|
      @sheets[i] = Array.new(y)
      @sheets[i].each_index {|j| @sheets[i][j] = Array.new(x)}
    end
  end
  
  def fill
    raise if @thickness != 1
    (0...@xlength).each {|a| (0...@ylength).each {|b| @sheets[0][b][a] = a+b*@xlength+1}}
  end
  
  def peek
    @sheets.each_with_index do |sheet,i|
      puts "Sheet " + i.to_s + ":"
      sheet.each {|row| puts row.to_s}
      puts ""
    end
  end
  
  def rotate!
    new_sheets = Array.new(@sheets.length)
    new_sheets.each_index do |i|
      new_sheets[i] = Array.new(@xlength)
      (0...@xlength).each do |a|
        new_sheets[i][a] = Array.new(@ylength)
        (0...@ylength).each {|b| new_sheets[i][a][b] = @sheets[i][@ylength-b-1][a]}
      end
    end
    @xlength,@ylength = @ylength,@xlength
    @sheets = new_sheets
  end
  
  def fold_bottom_to_top!
    raise if @ylength % 2 != 0
    new_sheets = Array.new(2*@thickness)
    (0...@thickness).each do |i|
      new_sheets[i] = Array.new(@ylength/2)
      new_sheets[i+@thickness] = Array.new(@ylength/2)
      (0...@ylength/2).each do |b|
        new_sheets[i][b] = Array.new(@xlength)
        new_sheets[i+@thickness][@ylength/2 - b-1] = Array.new(@xlength)
        (0...@xlength).each do |a|
          new_sheets[i][b][a] = @sheets[i][b][a]
          new_sheets[i+@thickness][@ylength/2 - b-1][a] = @sheets[@thickness-i-1][@ylength/2+b][a]
        end
      end
    end
    @ylength /= 2
    @thickness *= 2
    @sheets = new_sheets
  end
  
  def fold!(k)o
    k.times {rotate!}
    fold_bottom_to_top!
    (4-k).times {rotate!}
  end
  
  def unfold_bottom_to_top!
    raise if @thickness % 2 != 0
    new_sheets = Array.new(@thickness/2)
    (0...@thickness/2).each do |i|
      new_sheets[i] = Array.new(2*@ylength)
      (0...@ylength).each do |b|
        new_sheets[i][b] = Array.new(@xlength)
        new_sheets[i][2*@ylength-b-1] = Array.new(@xlength)
        (0...@xlength).each do |a|
          new_sheets[i][b][a] = @sheets[i][b][a]
          new_sheets[i][2*ylength-b-1][a] = @sheets[@thickness-i-1][b][a]
        end
      end
    end
    @ylength *= 2
    @thickness /= 2
    @sheets = new_sheets
  end
  
  def unfold!(k)
    k.times {rotate!}
    unfold_bottom_to_top!
    (4-k).times {rotate!}
  end
  
  def readdown
    raise if @xlength > 1 or @ylength > 1
    (0...@thickness).map {|i| @sheets[@thickness-i-1][0][0]}
  end
  
  def writedown array
    raise if @xlength > 1 or @ylength > 1 or @thickness != array.length
    array.each_with_index {|v,i| @sheets[@thickness-i-1][0][0] = v}
  end
  
  def execute! command
    command.split("").each {|c| fold! @@dict[c]}
  end
  
  def make_dup_of! fp
    @sheets = fp.sheets.dup
    @xlength = fp.xlength
    @ylength = fp.ylength
    @thickness = fp.thickness
  end
  
  def get_dup
    fp = FoldedPaper.new(1,1)
    fp.make_dup_of! self
    fp
  end
  
  def equals? fp
    return false if @xlength != fp.xlength or @ylength != fp.ylength or @thickness != fp.thickness
    (0...@thickness).each do |i|
      (0...@xlength).each do |a|
        (0...@ylength).each do |b|
          return false if @sheets[i][b][a] != fp.sheets[i][b][a]
        end
      end
    end
    return true
  end
  
  def is_valid? unfolded_x, unfolded_y
    if @thickness == 1
      fp = FoldedPaper.new(@xlength,@ylength)
      fp.fill
      return fp.equals?(self)
    end
  
    (0...@thickness).each do |i|
      (0...@xlength).each do |a|
        (0...@ylength).each do |b|
          value = @sheets[i][b][a]
          neighbors = [[a,b-1],[a,b+1],[a-1,b],[a+1,b]].select do |x,y|
            x >= 0 and y >= 0 and x < @xlength and y < @ylength
          end
          neighbor_values = neighbors.map {|x,y| @sheets[i][y][x]}
          if neighbor_values.detect {|n_val| not [1,unfolded_x].include?((value-n_val).abs)}
            return false
          end
        end
      end
    end
    return true
  end
  
  def find_solutions unfolded_x, unfolded_y
    solutions = []
    if is_valid? unfolded_x, unfolded_y
      return [""] if @thickness == 1
      (0..3).each do |k|
        fp = get_dup
        fp.unfold! k
        if fp.xlength <= unfolded_x and fp.ylength <= unfolded_y
          fp.find_solutions(unfolded_x,unfolded_y).each {|solution| solutions.push(solution + @@rev_dict[k])}
        end
      end
    end
    solutions
  end
end

def fold(x,y,s)
  fp = FoldedPaper.new(x,y)
  fp.fill
  fp.execute! s
  fp.readdown
end

def check_fold x,y,array
  fp = FoldedPaper.new(1,1,x*y)
  fp.writedown array
  fp.find_solutions(x,y)[0]
end