# vim: sw=2 sts=2 nu tw=0 expandtab nowrap:


class Formatter

  @@default = { ICE => "*",
                VAPOR => "0",
                VACUUM => " " 
  }
  def initialize chars={}
    @chars = 
      Hash[ *chars.to_a.map{ |(k,v)| [k, v || @@default[k] ] }.flatten ]
  end # def initialize colors={}

  def to_file( source, file, comment = nil )
    File.open( "#{file}.txt", "w" ) do
      | f |
      source.each_line{
        |line|
        line.each do
          | cell |
          f.print @chars[cell]
        end
        f.puts
      }
    end
  end
  
end
