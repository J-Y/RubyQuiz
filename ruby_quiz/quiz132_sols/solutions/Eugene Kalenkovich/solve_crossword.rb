class CrossTempl
  def initialize(templ)
    @tmpl=templ.collect { |line| line.split(//) }
    @words=[]
    @tmpl.each_index do |i|
      @tmpl[i].each_with_index do |char, j|
        if char!='#'
          if (j==0||@tmpl[i][j-1]=='#') && !@tmpl[i][j+1].nil? && @tmpl[i][j+1]!='#'
            @words << [i,j,0] if self.template(i,j,0).include?('_')
          end
          if (i==0||@tmpl[i-1][j]=='#') && !@tmpl[i+1].nil? && @tmpl[i+1][j]!='#'
            @words << [i,j,1] if self.template(i,j,1).include?('_')
          end
        end
      end
    end
    @words.sort! {|a,b| a[0]+a[1]<=>b[0]+b[1]}
  end

  def template(i,j,dir)
    str=''
    chr=@tmpl[i][j]
    while !chr.nil? && chr!='#'
      str<<chr
      i+=dir
      j+=1-dir
      break if @tmpl[i].nil?
      chr=@tmpl[i][j]
    end
    str
  end

  def [](idx)
    ar=@words[idx]
    return nil if ar.nil?
    template(ar[0],ar[1],ar[2])
  end

  def []=(idx,word)
    ar=@words[idx]
    i=ar[0]; j=ar[1];
    word.split(//).each do |chr|
      @tmpl[i][j]=chr
      i+=ar[2]
      j+=1-ar[2]
    end
  end

  def to_s
    @tmpl.each do |line|
      lstr=line.to_s
      puts lstr.gsub(/#/,' ').gsub(/(.)/) {"#{$&} "}
    end
  end

end

$words=[]
File.open("/usr/share/dict/words") {|f| f.readlines}.each do |word|
  w=word.upcase.delete("^A-Z")
  l=w.length
  $words[l]||=[]
  $words[l]<<w
end
$words.each {|ar| ar.uniq! if ar }

tfile=ARGV[0]
if tfile.nil?
  STDERR.puts "please provide a template file"
  exit 1
end

tmpl=File.read(tfile).split(/\n/).collect{|line| line.gsub(/\s/,'').upcase}
$ct=CrossTempl.new(tmpl)

def findWord(i)
  pattern=$ct[i]
  return true if pattern.nil?
  choices=$words[pattern.length].grep(/\A#{pattern.tr("_", ".")}\Z/).sort_by { rand }
  until choices.empty?
    guess=choices.pop
    $ct[i]=guess
    puts $ct
    return true if findWord(i+1)
    break if i>0 && rand(2)==1 # fighting incorrect word sorting
                               # by un-ballancing search
  end
  $ct[i]=pattern
  return false
end

if findWord(0)
  puts $ct
else
  puts "O-ops"
end
