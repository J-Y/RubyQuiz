class DayRange
  def initialize(days, lang='en', form=nil)
    form == nil ? @type = 0 : @type = 1 # Abbreviated or full name?
    @day_str_array = send "day_#{lang}" # 'lang' one of: en fr de es it
    @day_num_array = Array.new
    @days = days
    parse_args
  end

  def to_s
    s = String.new

    # Offset is the difference between numeric day values
    offset = Array.new
    f = @day_num_array[0]
    @day_num_array[1..-1].each do |n|
      offset << n - f
      f = n
    end

    s += "#{@day_str_array[@day_num_array[0]-1][@type]} "
    @day_num_array[1..-1].each_with_index do |v,i|
      if i < @day_num_array[1..-1].size
        if offset[i] == 1 and offset[i+1] == 1 # Found a range?
          s += "-" unless s[-1] == 45 # "-"
          next                                 # then move along...
        else
          s += " #{@day_str_array[v-1][@type]}" # otherwise add the name.
          next
        end
      else
        s += " #{@day_str_array[i][@type]}"
      end
    end
    # cleanup and return string
    s.gsub!(" -","-")
    s.gsub!("- ","-")
    s.gsub!(/ {2,}/," ")
    s.gsub!(" ",", ")
    s
  end

  # Maybe you just want the day names
  def to_str
    s = String.new
    @day_num_array.each { |n| s += "#{@day_str_array[n-1][@type]} " }
    s.strip!
  end

  # Maybe you want them in an array
  def to_a
    a = Array.new
    @day_num_array.each { |n| a << @day_str_array[n-1][@type] }
    a
  end

  private
  def parse_args
    if @days[0].class == Fixnum
      @day_num_array = @days.sort!
      if @day_num_array[-1] > 7
        raise ArgumentError, "Argument out of range: #{@day_num_array[-1]}"
      end
    else
      @days.each do |d|
        if @day_str_array.flatten.include?(d)
          indice = case @day_str_array.flatten.index(d)
            when 0..1:   1
            when 2..3:   2
            when 4..5:   3
            when 6..7:   4
            when 8..9:   5
            when 10..11: 6
            when 12..13: 7
          end
          @day_num_array << indice
        else
          raise ArgumentError, "Bad argument: #{d}"
        end
      end
      @day_num_array.sort!
    end
  end

  def day_en
    [['Mon','Monday'],['Tue','Tuesday'],['Wed','Wednesday'],['Thu','Thursday'],
     ['Fri','Friday'],['Sat','Saturday'],['Sun','Sunday']]
  end

  def day_fr
    [['lun','lundi'],['mar','mardi'],['mer','mercredi'],['jeu','jeudi'],
     ['ven','vendredi'],['sam','samedi'],['dim','dimanche']]
  end

  def day_es
    [['lun','lunes'],['mar','martes'],['mie','miércoles'],['jue','jueves'],
     ['vie','viernes'],['sab','sábado'],['dom','domingo']]
  end

  def day_de
    [['Mon','Montag'],['Die','Dienstag'],['Mit','Mittwoch'],['Don','Donnerstag'],
     ['Fre','Freitag'],['Sam','Samstag'],['Son','Sonntag']]
  end

  def day_it
    [['lun','lunedì'],['mar','martedì'],['mer','mercoledì'],['gio','giovedì'],
     ['ven','venerdì'],['sab','sabato'],['dom','domenica']]
  end

end
