require 'table'

class Morse < Table

  def compose
    @table['.'] = 'E'
    @table['..'] = 'I'
    @table['.-'] = 'A'
    @table['...'] = 'S'
    @table['..-'] = 'U'
    @table['....'] = 'H'
    @table['...-'] = 'V'
    @table['..-.'] = 'F'
    @table['.-.'] = 'R'
    @table['.--'] = 'W'
    @table['.-..'] = 'R'
    @table['.--.'] = 'P'
    @table['.---'] = 'G'
    @table['-'] = 'T'
    @table['-.'] = 'N'
    @table['--'] = 'M'
    @table['-..'] = 'D'
    @table['-.-'] = 'K'
    @table['-...'] = 'B'
    @table['-..-'] = 'X'
    @table['-.-.'] = 'C'
    @table['-.--'] = 'Y'
    @table['--.'] = 'G'
    @table['---'] = 'O'
    @table['--..'] = 'Z'
    @table['--.-'] = 'Q'
  end

end
