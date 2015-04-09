# vim: sts=2 sw=2 ft=ruby expandtab nu tw=0:
module HTMLOutput
  def to_s decoration = false
    %{<h1>A Magic Square of order #{@order}</h1>
    <table#{decoration ? " border=\"1\"":""} class="magic-square">\n} <<
        @data.map{ |line|
                        %{   <tr>\n} << line.map{ |cell|  
                                   %{      <td>%d</td>} % cell 
                                }.join("\n") << %{\n      </tr>}
                      }.join("\n") << "\n</table>" 
  end
end
