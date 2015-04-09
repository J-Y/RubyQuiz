class BigCo
  attr_reader :text
  Matches={"("=>")","["=>"]","{"=>"}"}
  def initialize(text)
    @text=text.gsub("\s","")
    parse
  end
  def parse
    open_containers=""
    can_close=false
    @text.each_byte do |a|
      test_item=a.chr
      if Matches.has_key?(test_item) then
        open_containers<<test_item
        can_close=false
      elsif Matches.has_value?(test_item) then
        raise "Closing empty container" unless can_close
        lastopen=open_containers.slice!(-1)
          raise "Closing unopenned container" unless lastopen
          raise "Closing incorrect container" unless test_item==Matches[lastopen.chr]
      elsif test_item=="B" then
        raise "Unpacked bracket" unless open_containers!=""
        can_close=true
      end
    end
    raise "Non-closed containers" unless open_containers==""
  rescue
    puts $!
    exit 1
  end
end
if __FILE__ == $0
text_in=ARGF.read
puts BigCo.new(text_in).text
end
