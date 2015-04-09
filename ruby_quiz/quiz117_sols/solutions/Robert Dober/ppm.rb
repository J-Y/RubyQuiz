# vim: sw=2 sts=2 nu tw=0 expandtab nowrap:


class Formatter

  @@default = { ICE => "255/255/255",
                VAPOR => "255/0/255",
                VACUUM => "0/0/0" 
  }

  def initialize colors={}
    @colors = {}
    colors.each do
      | element, color |
      color ||= @@default[element]
      @colors[ element ] = " " << color.gsub("/", " ") << " "
    end # colors.each do
  end # def initialize colors={}

  def to_file( source, file, comment = nil )
    comment ||= file
    File.open( "#{file}.ppm", "w" ) do
      | f |
      f.puts "P3 #{source.columns} #{source.lines} 255"
      f.puts "#"
      f.puts "# #{comment}"
      f.puts "#"
      source.each_line{
        |line|
        count = 0
        line.each do
          | cell |
          s = @colors[cell]
          if count + s.size > 70 then
            f.puts 
            count = 0
          end
          count += s.size
          f.print s
        end
        f.puts unless count.zero?
      }
    end
  end
  
end
